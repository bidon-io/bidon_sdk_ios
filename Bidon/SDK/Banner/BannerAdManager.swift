//
//  BannerManager.swift
//  Bidon
//
//  Created by Bidon Team on 26.08.2022.
//

import Foundation
import UIKit


protocol BannerAdManagerDelegate: AnyObject {
    func adManager(_ adManager: BannerAdManager, didFailToLoad error: SdkError)
    func adManager(_ adManager: BannerAdManager, didLoad ad: Ad)
    func adManager(_ adManager: BannerAdManager, didPayRevenue revenue: AdRevenue, ad: Ad)
}


final class BannerAdManager: NSObject {
    private typealias AuctionInfo = AuctionRequest.ResponseBody
    
    fileprivate typealias AuctionControllerType = ConcurrentAuctionController<AnyAdViewDemandProvider>
    fileprivate typealias WaterfallControllerType = DefaultWaterfallController<AnyAdViewBid>
    
    fileprivate enum State {
        case idle
        case preparing
        case auction(controller: AuctionControllerType)
        case loading(controller: WaterfallControllerType)
        case ready(bid: AdViewBid)
    }
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private var state: State = .idle
    
    let placement: String
    
    weak var delegate: BannerAdManagerDelegate?
    
    private lazy var adRevenueObserver: AdRevenueObserver = {
        let observer = BaseAdRevenueObserver()
        observer.ads = { [weak self] in
            guard let self = self else { return [] }
            return self.state.ads
        }
        observer.onRegisterAdRevenue = { [weak self] ad, revenue in
            guard let self = self else { return }
            self.delegate?.adManager(self, didPayRevenue: revenue, ad: ad)
        }
        return observer
    }()
    
    init(placement: String = "") {
        self.placement = placement
        super.init()
    }
    
    var bid: AdViewBid? {
        switch state {
        case .ready(let bid): return bid
        default: return nil
        }
    }
    
    func prepareForReuse() {
        state = .idle
    }
    
    func loadAd(
        context: AdViewContext,
        pricefloor: Price
    ) {
        guard state.isIdle else {
            Logger.warning("Banner ad manager is not idle. Loading attempt is prohibited.")
            return
        }
        
        fetchAuctionInfo(
            context,
            pricefloor: pricefloor
        )
    }
    
    private func fetchAuctionInfo(
        _ context: AdViewContext,
        pricefloor: Price
    ) {
        state = .preparing
        
        let request = AuctionRequest { (builder: AdViewAuctionRequestBuilder) in
            builder.withPlacement(placement)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withAuctionId(UUID().uuidString)
            builder.withFormat(context.format)
            builder.withPricefloor(pricefloor)
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
        
        let observer = BaseMediationObserver(
            auctionId: auctionInfo.auctionId,
            auctionConfigurationId: auctionInfo.auctionConfigurationId,
            adType: .banner
        )
        
        let elector = StrictLineItemElector(
            items: auctionInfo.lineItems,
            observer: observer
        )
        
        let auction = AuctionControllerType { (builder: AdViewConcurrentAuctionControllerBuilder) in
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withRounds(auctionInfo.rounds)
            builder.withElector(elector)
            builder.withPricefloor(auctionInfo.pricefloor)
            builder.withContext(context)
            builder.withMediationObserver(observer)
            builder.withAdRevenueObserver(self.adRevenueObserver)
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
                self.sendMediationAttemptReport(observer.report)
                self.state = .idle
                self.delegate?.adManager(self, didFailToLoad: error)
            }
        }
        
        state = .auction(controller: auction)
    }
    
    private func loadWaterfall<Observer: MediationObserver>(
        _ waterfall: AuctionControllerType.WaterfallType,
        observer: Observer
    ) {
        let waterfall = WaterfallControllerType(
            waterfall,
            observer: observer,
            timeout: .unknown
        )
        
        state = .loading(controller: waterfall)
        
        waterfall.load { [weak self, unowned observer] result in
            guard let self = self else { return }
            
            self.sendMediationAttemptReport(observer.report)
            
            switch result {
            case .success(let bid):
                let unwrapped = bid.unwrapped()
                self.state = .ready(bid: unwrapped)
                
                let ad = AdContainer(bid: bid)
                self.delegate?.adManager(self, didLoad: ad)
            case .failure(let error):
                self.state = .idle
                self.delegate?.adManager(self, didFailToLoad: error)
            }
        }
    }
    
    private func sendMediationAttemptReport<T: MediationAttemptReport>(_ report: T) {
        let request = StatisticRequest { builder in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withExt(sdk.ext)
            builder.withAdType(.banner)
            builder.withMediationReport(report)
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
    
    var ads: [Ad] {
        switch self {
        case .auction(let controller):
            return controller.currentBids.map(AdContainer.init)
        case .loading(let controller):
            return controller.bids.map(AdContainer.init)
        case .ready(let bid):
            return [AdContainer(bid: bid)]
        default: return []
        }
    }
}
