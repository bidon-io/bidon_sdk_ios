//
//  BannerManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import UIKit


protocol BannerAdManagerDelegate: AuctionControllerDelegate {
    func didFailToLoad(_ error: Error)
    func didLoad(_ ad: Ad)
}


final class BannerAdManager: NSObject {
    fileprivate typealias AuctionControllerType = ConcurrentAuctionController<AnyAdViewDemandProvider>
    fileprivate typealias WaterfallControllerType = WaterfallController<AnyAdViewDemand>
    
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
        
        state = .preparing
        
        let auctionId: String = UUID().uuidString
        
        let request = AuctionRequest { (builder: AdViewAuctionRequestBuilder) in
            builder.withPlacement(placement)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withAuctionId(auctionId)
            builder.withExt(sdk.ext)
        }
        
        Logger.verbose("Banner ad manager performs request: \(request)")
        
        networkManager.perform(
            request: request
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                Logger.verbose("Banner ad manager performs request: \(request)")
                
                let auction = AuctionControllerType { (builder: AdViewConcurrentAuctionControllerBuilder) in
                    builder.withAdaptersRepository(self.sdk.adaptersRepository)
                    builder.withRounds(response.rounds, lineItems: response.lineItems)
                    builder.withPricefloor(response.minPrice)
                    builder.withDelegate(self)
                    builder.withContext(context)
                    builder.withAuctionId(auctionId)
                }
                
                auction.load()
                self.state = .auction(controller: auction)
                
                break
            case .failure(let error):
                self.state = .idle
                Logger.warning("Banner ad manager did fail to load ad with error: \(error)")
            }
        }
    }
    
    private func trackMediationResult() {
        let request = StatisticRequest { builder in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withExt(sdk.ext)
            builder.withMediationResult(MediationObserver(id: UUID().uuidString, configurationId: 0))
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent statistics with result: \(result)")
        }
    }
}


extension BannerAdManager: AuctionControllerDelegate {
    func controllerDidStartAuction(_ controller: AuctionController) {
        delegate?.controllerDidStartAuction(controller)
    }
    
    func controller(_ controller: AuctionController, didStartRound round: AuctionRound, pricefloor: Price) {
        delegate?.controller(controller, didStartRound: round, pricefloor: pricefloor)
    }
    
    func controller(_ controller: AuctionController, didReceiveAd ad: Ad, provider: DemandProvider) {
        delegate?.controller(controller, didReceiveAd: ad, provider: provider)
    }
    
    func controller(_ controller: AuctionController, didCompleteRound round: AuctionRound) {
        delegate?.controller(controller, didCompleteRound: round)
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        guard let controller = controller as? AuctionControllerType else { return }
        
        delegate?.controller(controller, completeAuction: winner)
        
        let waterfall = WaterfallControllerType(
            controller.waterfall,
            timeout: .unknown
        )
        
        state = .loading(controller: waterfall)
        
        waterfall.load { [weak self] result in
            guard let self = self else { return }
            
            self.trackMediationResult()
            switch result {
            case .success(let demand):
                self.state = .ready(demand: demand.unwrapped())
                self.delegate?.didLoad(demand.ad)
            case .failure(let error):
                self.state = .idle
                self.delegate?.didFailToLoad(error)
            }
        }
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        trackMediationResult()
        state = .idle
        delegate?.controller(controller, failedAuction: error)
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
