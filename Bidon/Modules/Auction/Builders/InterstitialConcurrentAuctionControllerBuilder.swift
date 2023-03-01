//
//  InterstitialConcurrentAuctionControllerBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 11.08.2022.
//

import Foundation


final class InterstitialConcurrentAuctionControllerBuilder<MediationObserverType: MediationObserver>: BaseConcurrentAuctionControllerBuilder<AnyInterstitialDemandProvider, MediationObserverType> {
    
    override func providers(_ demands: [String]) -> [AnyAdapter: AnyInterstitialDemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: InterstitialDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                if let adapter = adapter {
                    let any = AnyAdapter(adapter: adapter)
                    result[any] = try adapter.interstitial().wrapped()
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
