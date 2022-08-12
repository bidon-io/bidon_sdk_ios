//
//  InterstitialConcurrentAuctionControllerBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class InterstitialConcurrentAuctionControllerBuilder: BaseConcurrentAuctionControllerBuilder, ConcurrentAuctionControllerBuilder {
    let adType: AdType = .interstitial
    
    override func providers(_ demands: [String]) -> [String: DemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: InterstitialDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                result[id] = try adapter?.interstitial()
            } catch {
                Logger.debug("Error while creating interstitial in adapter: \(adapter.debugDescription)")
            }
            
            return result
        }
    }
}
