//
//  BannerManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import UIKit


protocol BannerAdManagerDelegate: AnyObject {
    func adManagerDidStartAuction(_ adManager: BannerAdManager)
    func adManager(_ adManager: BannerAdManager, didFailToLoad error: SdkError)
    func adManager(_ adManager: BannerAdManager, didLoad demand: AdViewDemand)
    func adManager(_ adManager: BannerAdManager, didStartAuctionRound round: AuctionRound, pricefloor: Price)
    func adManager(_ adManager: BannerAdManager, didReceiveBid ad: Ad, provider: AdViewDemandProvider)
    func adManager(_ adManager: BannerAdManager, didCompleteAuctionRound round: AuctionRound)
    func adManager(_ adManager: BannerAdManager, didCompleteAuction demand: AdViewDemand?)
}


final class BannerAdManager: NSObject {
    fileprivate typealias AuctionControllerType = ConcurrentAuctionController<AnyAdViewDemandProvider, DefaultMediationObserver>
    fileprivate typealias WaterfallControllerType = DefaultWaterfallController<AnyAdViewDemand, DefaultMediationObserver>
    
    private typealias AuctionInfo = AuctionRequest.ResponseBody
    private typealias DemandEventType = DemandEvent<AnyAdViewDemandProvider>
    
    fileprivate enum State {
        case idle
        case preparing
        case auction(controller: AuctionControllerType)
        case loading(controller: WaterfallControllerType)
        case ready(demand: AdViewDemand)
    }
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private var state: State = .idle
    
    let placement: String
    
    weak var delegate: BannerAdManagerDelegate?
    
    init(placement: String = "") {
        self.placement = placement
        super.init()
    }
    
    var demand: AdViewDemand? {
        switch state {
        case .ready(let demand): return demand
        default: return nil
        }
    }
    
    func prepareForReuse() {
        state = .idle
    }
    
    func loadAd(context: AdViewContext) {
        guard state.isIdle else {
            Logger.warning("Banner ad manager is not idle. Loading attempt is prohibited.")
            return
        }
        
        fetchAuctionInfo(context)
    }
    
    private func fetchAuctionInfo(_ context: AdViewContext) {
        state = .preparing

        let request = AuctionRequest { (builder: AdViewAuctionRequestBuilder) in
            builder.withPlacement(placement)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withAuctionId(UUID().uuidString)
            builder.withExt(sdk.ext)
        }
        
        Logger.verbose("Banner ad manager performs request: \(request)")
        
        networkManager.perform(
            request: request
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.performAuction(response, context: context)
            case .failure(let error):
                Logger.warning("Banner ad manager did fail to load ad with error: \(error)")
                self.state = .idle
                self.delegate?.adManager(self, didFailToLoad: SdkError(error))
            }
        }
    }
    
    private func performAuction(
        _ auctionInfo: AuctionInfo,
        context: AdViewContext
    ) {
        Logger.verbose("Banner ad manager will start auction: \(auctionInfo)")
        
        let observer = DefaultMediationObserver(
            id: auctionInfo.auctionId,
            configurationId: auctionInfo.auctionConfigurationId
        )
        
        let auction = AuctionControllerType { (builder: AdViewConcurrentAuctionControllerBuilder) in
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withRounds(auctionInfo.rounds, lineItems: auctionInfo.lineItems)
            builder.withPricefloor(auctionInfo.minPrice)
            builder.withContext(context)
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
                self.delegate?.adManager(self, didCompleteAuction: waterfall.first()?.unwrapped())
            case .failure(let error):
                self.sendAuctionStatistics(observer.log)
                self.state = .idle
                
                self.delegate?.adManager(self, didCompleteAuction: nil)
                self.delegate?.adManager(self, didFailToLoad: error)
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
        
        waterfall.load { [weak self, unowned observer]  result in
            guard let self = self else { return }
            
            self.sendAuctionStatistics(observer.log)
            
            switch result {
            case .success(let demand):
                let unwrapped = demand.unwrapped()
                self.state = .ready(demand: unwrapped)
                self.delegate?.adManager(self, didLoad: unwrapped)
            case .failure(let error):
                self.state = .idle
                self.delegate?.adManager(self, didFailToLoad: error)
            }
        }
    }
    
    private func handleAuctionEvent(_ auctionEvent: DemandEventType) {
        switch auctionEvent {
        case .didStartAuction:
            delegate?.adManagerDidStartAuction(self)
        case .didStartRound(let round, let pricefloor):
            delegate?.adManager(self, didStartAuctionRound: round, pricefloor: pricefloor)
        case .didReceiveBid(let bid):
            delegate?.adManager(self, didReceiveBid: bid.ad, provider: bid.provider.wrapped)
        case .didCompleteRound(let round):
            delegate?.adManager(self, didCompleteAuctionRound: round)
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

private extension BannerAdManager.State {
    var isIdle: Bool {
        switch self {
        case .idle: return true
        default: return false
        }
    }
}
