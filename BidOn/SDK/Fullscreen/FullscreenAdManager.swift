//
//  RewardedAd.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit


protocol FullscreenAdManagerDelegate: FullscreenImpressionControllerDelegate, AuctionControllerDelegate {
    func didFailToLoad(_ error: Error)
    func didLoad(_ ad: Ad)
}


final class FullscreenAdManager<RequestBuilderType, AuctionBuilderType, ImpressionControllerType>: NSObject where
RequestBuilderType: AuctionRequestBuilder,
AuctionBuilderType: ConcurrentAuctionControllerBuilder,
ImpressionControllerType: FullscreenImpressionController, ImpressionControllerType.Context == UIViewController {
    
    fileprivate enum State {
        case idle
        case preparing
        case auction(controller: AuctionController)
        case loading(controller: WaterfallController)
        case ready(demand: Demand)
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
        
        let auctionId: String = UUID().uuidString
        
        let request = AuctionRequest { (builder: RequestBuilderType) in
            builder.withPlacement(placement)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withAuctionId(auctionId)
            builder.withExt(sdk.ext)
        }
        
        Logger.verbose("Fullscreen ad manager performs request: \(request)")
        
        networkManager.perform(
            request: request
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                Logger.verbose("Fullscreen ad manager performs request: \(request)")
                
                let auction = ConcurrentAuctionController { (builder: AuctionBuilderType) in
                    builder.withAdaptersRepository(self.sdk.adaptersRepository)
                    builder.withRounds(response.rounds, lineItems: response.lineItems)
                    builder.withPricefloor(response.minPrice)
                    builder.withDelegate(self)
                    builder.withAuctionId(auctionId)
                }
                
                auction.load()
                self.state = .auction(controller: auction)
                
                break
            case .failure(let error):
                self.state = .idle
                Logger.warning("Fullscreen ad manager did fail to load ad with error: \(error)")
                self.delegate?.didFailToLoad(error)
            }
        }
    }
    
    func show(from rootViewController: UIViewController) {
        switch state {
        case .ready(let demand):
            let controller = try! ImpressionControllerType(demand: demand)
            controller.delegate = self
            state = .impression(controller: controller)
            controller.show(from: rootViewController)
        default:
            delegate?.didFailToPresent(nil, error: SdkError.internalInconsistency)
        }
    }
}


extension FullscreenAdManager: AuctionControllerDelegate {
    func controllerDidStartAuction(_ controller: AuctionController) {}
    
    func controller(
        _ controller: AuctionController,
        didStartRound round: AuctionRound,
        pricefloor: Price
    ) {
        delegate?.controller(
            controller,
            didStartRound: round,
            pricefloor: pricefloor
        )
    }
    
    func controller(
        _ controller: AuctionController,
        didReceiveAd ad: Ad,
        provider: DemandProvider
    ) {
        delegate?.controller(
            controller,
            didReceiveAd: ad,
            provider: provider
        )
    }
    
    func controller(
        _ controller: AuctionController,
        didCompleteRound round: AuctionRound
    ) {
        delegate?.controller(
            controller,
            didCompleteRound: round
        )
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        delegate?.controller(
            controller,
            completeAuction: winner
        )
        
        let waterfall = DefaultWaterfallController(
            controller.waterfall,
            timeout: .unknown
        )
        
        waterfall.delegate = self
        state = .loading(controller: waterfall)
        waterfall.load()
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        state = .idle
        
        delegate?.controller(controller, failedAuction: error)
        delegate?.didFailToLoad(error)
    }
}


extension FullscreenAdManager: WaterfallControllerDelegate {
    func controller(_ controller: WaterfallController, didLoadDemand demand: Demand) {
        state = .ready(demand: demand)
        delegate?.didLoad(demand.ad)
    }
    
    func controller(_ controller: WaterfallController, didFailToLoad error: SdkError) {
        state = .idle
        delegate?.didFailToLoad(error)
    }
}


extension FullscreenAdManager: FullscreenImpressionControllerDelegate {
    func didPresent(_ ad: Ad) {
        delegate?.didPresent(ad)
    }

    func didHide(_ ad: Ad) {
        state = .idle
        delegate?.didHide(ad)
    }
    
    func didClick(_ ad: Ad) {
        delegate?.didClick(ad)
    }

    func didFailToPresent(_ ad: Ad?, error: Error) {
        state = .idle
        delegate?.didFailToPresent(ad, error: error)
    }
    
    func didReceiveReward(_ reward: Reward, ad: Ad) {
        delegate?.didReceiveReward(reward, ad: ad)
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
