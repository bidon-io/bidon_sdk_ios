//
//  InterstitialConcurrentAuctionControllerBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class InterstitialConcurrentAuctionControllerBuilder: BaseConcurrentAuctionControllerBuilder<AnyInterstitialDemandProvider> {
    override var adType: AdType { .interstitial }
    
    override func providers(_ demands: [String]) -> [String: AnyInterstitialDemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: InterstitialDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                if let provider = try adapter?.interstitial() {
                    result[id] = try provider.wrapped()
                }
            } catch {
                Logger.debug("Error while creating interstitial in adapter: \(adapter.debugDescription)")
            }
            
            return result
        }
    }
}


private extension InterstitialDemandProvider {
    func wrapped() throws -> AnyInterstitialDemandProvider {
        if self is DirectDemandProvider {
            return try AnyDirectDemandProvider(self)
        } else if self is ProgrammaticDemandProvider {
            return try AnyProgrammaticDemandProvider(self)
        } else {
            return try AnyDemandProvider(self)
        }
    }
}
