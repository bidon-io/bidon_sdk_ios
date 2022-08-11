//
//  Interstitial.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation


@objc(BDInterstitial)
public final class Interstitial: NSObject {
    fileprivate enum State {
        case idle
        case preparing
        case auction(controller: AuctionController)
        case loading
        case impression
    }
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @Injected(\.sdk)
    private var sdk: Sdk
       
    private var state: State = .idle
    
    @objc public let placement: String
    
    @objc public init(placement: String = "") {
        self.placement = placement
        super.init()
    }
    
    @objc public func loadAd() {
        guard state.isIdle else {
            Logger.warning("Trying to load already loading interstitial")
            return
        }
        
        let request = AuctionRequest { (builder: InterstitialAuctionRequestBuilder) in
            builder.withPlacement(placement)
            builder.withAdaptersRepository(sdk.adaptersRepository)
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withExt(sdk.ext)
        }
        
        networkManager.perform(
            request: request
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let auction = ConcurrentAuctionController { (builder: InterstitialConcurrentAuctionControllerBuilder) in
                    builder.withAdaptersRepository(self.sdk.adaptersRepository)
                    builder.withRounds(response.rounds, lineItems: response.lineItems)
                    builder.withPricefloor(response.minPrice)
                }
                
                auction.load()
                self.state = .auction(controller: auction)
                
                break
            case .failure(let error):
                self.state = .idle
                break
            }
        }
    }
}


private extension Interstitial.State {
    var isIdle: Bool {
        switch self {
        case .idle: return true
        default: return false
        }
    }
}
