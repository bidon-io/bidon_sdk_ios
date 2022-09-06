//
//  RewardedAd.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit


protocol FullscreenAdManagerDelegate: FullscreenImpressionControllerDelegate {
    func didStartAuction()
    func didStartAuctionRound(_ round: AuctionRound, pricefloor: Price)
    func didReceiveBid(_ ad: Ad)
    func didCompleteAuctionRound(_ round: AuctionRound)
    func didCompleteAuction(_ winner: Ad?)
    func didFailToLoad(_ error: SdkError)
    func didLoad(_ ad: Ad)
    func didPayRevenue(_ ad: Ad)
}


final class FullscreenAdManager<
    DemandProviderType,
    AuctionRequestBuilderType,
    AuctionControllerBuilderType,
    ImpressionControllerType
>: NSObject where
DemandProviderType: DemandProvider,
AuctionRequestBuilderType: AuctionRequestBuilder,
AuctionControllerBuilderType: BaseConcurrentAuctionControllerBuilder<DemandProviderType, DefaultMediationObserver>,
ImpressionControllerType: FullscreenImpressionController,
ImpressionControllerType.DemandType == DemandModel<DemandProviderType> {
    
    fileprivate typealias DemandType = DemandModel<DemandProviderType>
    fileprivate typealias AuctionControllerType = ConcurrentAuctionController<DemandProviderType, DefaultMediationObserver>
    fileprivate typealias WaterfallControllerType = DefaultWaterfallController<DemandType, DefaultMediationObserver>

    private typealias AuctionInfo = AuctionRequest.ResponseBody
    private typealias DemandEventType = DemandEvent<DemandProviderType>

    fileprivate enum State {
        case idle
        case preparing
        case auction(controller: AuctionControllerType)
        case loading(controller: DefaultWaterfallController<DemandType, DefaultMediationObserver>)
        case ready(demand: DemandType)
        case impression(controller: ImpressionControllerType)
    }
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private var state: State = .idle
    
    weak var delegate: FullscreenAdManagerDelegate?
    
    let placement: String
    
    init(placement: String = "") {
        self.placement = placement
        super.init()
    }
    
    func loadAd() {
        guard state.isIdle else {
            Logger.warning("Fullscreen ad manager is not idle. Loading attempt is prohibited.")
            return
        }
        
        fetchAuctionInfo()
    }
    
    
    private func fetchAuctionInfo() {
        state = .preparing
        
        let request = AuctionRequest { (builder: AuctionRequestBuilderType) in
            builder.withPlacement(placement)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withAuctionId(UUID().uuidString)
            builder.withExt(sdk.ext)
        }
        
        Logger.verbose("Fullscreen ad manager performs request: \(request)")
        
        networkManager.perform(
            request: request
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.performAuction(response)
            case .failure(let error):
                self.state = .idle
                Logger.warning("Fullscreen ad manager did fail to load ad with error: \(error)")
                self.delegate?.didFailToLoad(SdkError(error))
            }
        }
    }
    
    func show(from rootViewController: UIViewController) {
        switch state {
        case .ready(let demand):
            let controller = ImpressionControllerType(demand: demand)
            controller.delegate = self
            state = .impression(controller: controller)
            controller.show(from: rootViewController)
        default:
            delegate?.didFailToPresent(nil, error: SdkError.internalInconsistency)
        }
    }
    
    private func performAuction(_ auctionInfo: AuctionInfo) {
        Logger.verbose("Fullscreen ad manager will start auction: \(auctionInfo)")

        let observer = DefaultMediationObserver(
            id: auctionInfo.auctionId,
            configurationId: auctionInfo.auctionConfigurationId
        )
        
        let auction = AuctionControllerType { (builder: AuctionControllerBuilderType) in
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withRounds(auctionInfo.rounds, lineItems: auctionInfo.lineItems)
            builder.withPricefloor(auctionInfo.minPrice)
            builder.withObserver(observer)
        }
        
        weak var weakSelf = self
        auction.eventHandler = weakSelf?.handleAuctionEvent
        
        auction.load { [unowned observer, weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let waterfall):
                self.loadWaterfall(
                    waterfall,
                    observer: observer
                )
                self.delegate?.didCompleteAuction(waterfall.first()?.ad)
            case .failure(let error):
                self.sendAuctionStatistics(observer.log)
                self.state = .idle
                
                self.delegate?.didCompleteAuction(nil)
                self.delegate?.didFailToLoad(error)
            }
        }
        
        state = .auction(controller: auction)
    }
        
    private func loadWaterfall(
        _ waterfall: AuctionControllerType.WaterfallType,
        observer: AuctionControllerType.Observer
    ) {
        let waterfall = WaterfallControllerType(
            waterfall,
            observer: observer,
            timeout: .unknown
        )
        
        state = .loading(controller: waterfall)
        waterfall.load { [unowned observer, weak self] result in
            guard let self = self else { return }
            
            self.sendAuctionStatistics(observer.log)
            
            switch result {
            case .success(let demand):
                self.state = .ready(demand: demand)
                self.delegate?.didLoad(demand.ad)
            case .failure(let error):
                self.state = .idle
                self.delegate?.didFailToLoad(error)
            }
        }
    }
    
    private func handleAuctionEvent(_ auctionEvent: DemandEventType) {
        switch auctionEvent {
        case .didStartAuction:
            delegate?.didStartAuction()
        case .didStartRound(let round, let pricefloor):
            delegate?.didStartAuctionRound(round, pricefloor: pricefloor)
        case .didReceiveBid(let bid):
            bid.provider.revenueDelegate = self
            delegate?.didReceiveBid(bid.ad)
        case .didCompleteRound(let round):
            delegate?.didCompleteAuctionRound(round)
        }
    }
    
    private func sendAuctionStatistics<T: MediationLog>(_ log: T) {
        let request = StatisticRequest { builder in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withExt(sdk.ext)
            builder.withMediationResult(log)
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent statistics with result: \(result)")
        }
    }
}


extension FullscreenAdManager: FullscreenImpressionControllerDelegate {
    func didFailToPresent(_ impression: Impression?, error: SdkError) {
        state = .idle
        delegate?.didFailToPresent(impression, error: error)
    }
    
    func willPresent(_ impression: Impression) {
        networkManager.perform(request: ImpressionRequest { builder in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withExt(sdk.ext)
            builder.withImpression(impression)
        }) { result in
            Logger.debug("Sent show with result: \(result)")
        }
        
        delegate?.willPresent(impression)
    }
    
    func didHide(_ impression: Impression) {
        state = .idle
        delegate?.didHide(impression)
    }
    
    func didClick(_ impression: Impression) {
        delegate?.didClick(impression)
    }
    
    func didReceiveReward(_ reward: Reward, impression: Impression) {
        delegate?.didReceiveReward(reward, impression: impression)
    }
}


extension FullscreenAdManager: DemandProviderRevenueDelegate {
    func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        delegate?.didPayRevenue(ad)
    }
}


private extension FullscreenAdManager.State {
    var isIdle: Bool {
        switch self {
        case .idle: return true
        default: return false
        }
    }
}
