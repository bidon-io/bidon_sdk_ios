//
//  AdViewConcurrentAuctionControllerBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation



final class AdViewConcurrentAuctionControllerBuilder: BaseConcurrentAuctionControllerBuilder, ConcurrentAuctionControllerBuilder {
    let adType: AdType = .banner
    
    private var context: AdViewContext!
    
    @discardableResult
    public func withContext(_ context: AdViewContext) -> Self {
        self.context = context
        return self
    }
    
    override func providers(_ demands: [String]) -> [String: DemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: AdViewDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                result[id] = try adapter?.adView(context)
            } catch {
                Logger.debug("Error while creating banner in adapter: \(adapter.debugDescription)")
            }
            
            return result
        }
    }
}

