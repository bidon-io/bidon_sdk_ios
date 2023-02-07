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
    func adManager(_ adManager: BannerAdManager, didReceiveBid ad: Ad, provider: DemandProvider)
    func adManager(_ adManager: BannerAdManager, didCompleteAuctionRound round: AuctionRound)
    func adManager(_ adManager: BannerAdManager, didCompleteAuction winner: Ad?)
}


final class BannerAdManager: NSObject {
    private typealias AuctionInfo = AuctionRequest.ResponseBody
    
    fileprivate typealias BannerMediationObserver = DefaultMediationObserver<AnyAdViewDemandProvider>
    fileprivate typealias AuctionControllerType = ConcurrentAuctionController<AnyAdViewDemandProvider, BannerMediationObserver>
    fileprivate typealias WaterfallControllerType = DefaultWaterfallController<AnyAdViewDemand, BannerMediationObserver>
    
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
            builder.withAuctionId(UUID().uuidString)
            builder.withFormat(context.format)
            builder.withMinPrice(pricefloor)
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
        
        let observer = BannerMediationObserver(
            auctionId: auctionInfo.auctionId,
            auctionConfigurationId: auctionInfo.auctionConfigurationId,
            adType: .banner
        )
        
        observer.delegate = self
        
        let auction = AuctionControllerType { (builder: AdViewConcurrentAuctionControllerBuilder) in
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withRounds(auctionInfo.rounds, lineItems: auctionInfo.lineItems)
            builder.withPricefloor(auctionInfo.minPrice)
            builder.withContext(context)
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
                self.sendMediationAttemptReport(observer.report)
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
        
        waterfall.load { [weak self, unowned observer]  result in
            guard let self = self else { return }
            
            self.sendMediationAttemptReport(observer.report)
            
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
    
    private func sendMediationAttemptReport<T: MediationAttemptReport>(_ report: T) {
        let request = StatisticRequest { builder in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withExt(sdk.ext)
            builder.withAdType(.banner)
            builder.withMediationReport(report)
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent statistics with result: \(result)")
        }
    }
}


extension BannerAdManager: MediationObserverDelegate {
    func didStartAuction(_ auctionId: String) {
        delegate?.adManagerDidStartAuction(self)
    }
    
    func didStartAuctionRound(_ auctionRound: AuctionRound, pricefloor: Price) {
        delegate?.adManager(self, didStartAuctionRound: auctionRound, pricefloor: pricefloor)
    }
    
    func didReceiveBid(_ ad: Ad, provider: DemandProvider) {
        delegate?.adManager(self, didReceiveBid: ad, provider: provider)
    }
    
    func didFinishAuctionRound(_ auctionRound: AuctionRound) {
        delegate?.adManager(self, didCompleteAuctionRound: auctionRound)
    }
    
    func didFinishAuction(_ auctionId: String, winner: Ad?) {
        delegate?.adManager(self, didCompleteAuction: winner)
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
