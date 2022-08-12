//
//  RewardedConcurrentAuctionControllerBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class RewardedConcurrentAuctionControllerBuilder: BaseConcurrentAuctionControllerBuilder, ConcurrentAuctionControllerBuilder {
    let adType: AdType = .rewarded
    
    override func providers(_ demands: [String]) -> [String: DemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: RewardedAdDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                result[id] = try adapter?.rewardedAd()
            } catch {
                Logger.debug("Error while creating rewarded in adapter: \(adapter.debugDescription)")
            }
            
            return result
        }
    }
}
