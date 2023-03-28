//
//  RewardedAd.swift
//  Bidon
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import UIKit


protocol FullscreenAdManager: AnyObject {
    var isReady: Bool { get }
}

protocol FullscreenAdManagerDelegate: AnyObject {
    func adManager(_ adManager: FullscreenAdManager, didFailToLoad error: SdkError)
    func adManager(_ adManager: FullscreenAdManager, didLoad ad: Ad)
    func adManager(_ adManager: FullscreenAdManager, didFailToPresent impression: Impression?, error: SdkError)
    func adManager(_ adManager: FullscreenAdManager, willPresent impression: Impression)
    func adManager(_ adManager: FullscreenAdManager, didHide impression: Impression)
    func adManager(_ adManager: FullscreenAdManager, didClick impression: Impression)
    func adManager(_ adManager: FullscreenAdManager, didReward reward: Reward, impression: Impression)
    func adManager(_ adManager: FullscreenAdManager, didPayRevenue revenue: AdRevenue, ad: Ad)
}


final class BaseFullscreenAdManager<
    DemandProviderType,
    ObserverType,
    AuctionRequestBuilderType,
    AuctionControllerBuilderType,
    ImpressionControllerType,
    ImpressionRequestBuilderType
>: NSObject, FullscreenAdManager where
AuctionRequestBuilderType: AuctionRequestBuilder,
ObserverType: MediationObserver,
ObserverType.DemandProviderType == DemandProviderType,
AuctionControllerBuilderType: BaseConcurrentAuctionControllerBuilder<DemandProviderType, ObserverType>,
ImpressionControllerType: FullscreenImpressionController,
ImpressionControllerType.DemandType == DemandModel<DemandProviderType>,
ImpressionRequestBuilderType: ImpressionRequestBuilder {
    
    fileprivate typealias DemandType = DemandModel<DemandProviderType>
    fileprivate typealias AuctionControllerType = ConcurrentAuctionController<DemandProviderType, ObserverType>
    fileprivate typealias WaterfallControllerType = DefaultWaterfallController<DemandType, ObserverType>
    
    private typealias AuctionInfo = AuctionRequest.ResponseBody
    
    fileprivate enum State {
        case idle
        case preparing
        case auction(controller: AuctionControllerType)
        case loading(controller: WaterfallControllerType)
        case ready(demand: DemandType)
        case impression(controller: ImpressionControllerType)
    }
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private var state: State = .idle
    
    private weak var delegate: (any FullscreenAdManagerDelegate)?
    
    private let placement: String
    private let adType: AdType
    
    var isReady: Bool {
        switch state {
        case .ready: return true
        default: return false
        }
    }
    
    init(
        adType: AdType,
        placement: String,
        delegate: (any FullscreenAdManagerDelegate)?
    ) {
        self.delegate = delegate
        self.adType = adType
        self.placement = placement
        super.init()
    }
    
    func loadAd(pricefloor: Price) {
        guard state.isIdle else {
            Logger.warning("Fullscreen ad manager is not idle. Loading attempt is prohibited.")
            return
        }
        
        fetchAuctionInfo(pricefloor)
    }
    
    private func fetchAuctionInfo(_ pricefloor: Price) {
        state = .preparing
        
        let request = AuctionRequest { (builder: AuctionRequestBuilderType) in
            builder.withPlacement(placement)
            builder.withPricefloor(pricefloor)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
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
                self.delegate?.adManager(self, didFailToLoad: SdkError(error))
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
            let impression: FullscreenImpression? = nil
            delegate?.adManager(self, didFailToPresent: impression, error: .internalInconsistency)
        }
    }
    
    private func performAuction(_ auctionInfo: AuctionInfo) {
        Logger.verbose("Fullscreen ad manager will start auction: \(auctionInfo)")
        
        let observer = ObserverType(
            auctionId: auctionInfo.auctionId,
            auctionConfigurationId: auctionInfo.auctionConfigurationId,
            adType: adType
        )
        
        let elector = StrictLineItemElector(
            items: auctionInfo.lineItems,
            observer: observer
        )

        let auction = AuctionControllerType { (builder: AuctionControllerBuilderType) in
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withRounds(auctionInfo.rounds)
            builder.withElector(elector)
            builder.withRevenueDelegate(self)
            builder.withPricefloor(auctionInfo.pricefloor)
            builder.withObserver(observer)
        }
        
        auction.load { [unowned observer, weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let waterfall):
                self.loadWaterfall(
                    waterfall,
                    observer: observer
                )
            case .failure(let error):
                self.sendAuctionStatistics(observer.report)
                self.state = .idle
                
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
        waterfall.load { [unowned observer, weak self] result in
            guard let self = self else { return }
            
            self.sendAuctionStatistics(observer.report)
            
            switch result {
            case .success(let demand):
                self.state = .ready(demand: demand)
                self.delegate?.adManager(self, didLoad: demand.ad)
            case .failure(let error):
                self.state = .idle
                self.delegate?.adManager(self, didFailToLoad: error)
            }
        }
    }
    
    private func sendAuctionStatistics<T: MediationAttemptReport>(_ report: T) {
        let request = StatisticRequest { builder in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withExt(sdk.ext)
            builder.withAdType(adType)
            builder.withMediationReport(report)
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent statistics with result: \(result)")
        }
    }
    
    private func sendImpressionIfNeeded(
        _ impression: inout Impression,
        path: Route
    ) {
        guard impression.isTrackingAllowed(path) else { return }
        
        let request = ImpressionRequest { (builder: ImpressionRequestBuilderType) in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withExt(sdk.ext)
            builder.withImpression(impression)
            builder.withPath(path)
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent impression action '\(path)' with result: \(result)")
        }
        
        impression.markTrackedIfNeeded(path)
    }
}


extension BaseFullscreenAdManager: FullscreenImpressionControllerDelegate {
    func didFailToPresent(_ impression: inout Impression?, error: SdkError) {
        state = .idle
        delegate?.adManager(self, didFailToPresent: impression, error: error)
    }
    
    func willPresent(_ impression: inout Impression) {
        sendImpressionIfNeeded(&impression, path: .show)
        delegate?.adManager(self, willPresent: impression)
    }
    
    func didHide(_ impression: inout Impression) {
        state = .idle
        delegate?.adManager(self, didHide: impression)
    }
    
    func didClick(_ impression: inout Impression) {
        sendImpressionIfNeeded(&impression, path: .click)
        delegate?.adManager(self, didClick: impression)
    }
    
    func didReceiveReward(_ reward: Reward, impression: inout Impression) {
        sendImpressionIfNeeded(&impression, path: .reward)
        delegate?.adManager(self, didReward: reward, impression: impression)
    }
}


extension BaseFullscreenAdManager: DemandProviderRevenueDelegate {
    func provider(
        _ provider: any DemandProvider,
        didPay revenue: AdRevenue,
        ad: Ad
    ) {
        delegate?.adManager(self, didPayRevenue: revenue, ad: ad)
    }
}

private extension BaseFullscreenAdManager.State {
    var isIdle: Bool {
        switch self {
        case .idle: return true
        default: return false
        }
    }
}
