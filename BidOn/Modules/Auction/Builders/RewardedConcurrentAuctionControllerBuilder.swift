//
//  RewardedConcurrentAuctionControllerBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class RewardedConcurrentAuctionControllerBuilder<MediationObserverType: MediationObserver>: BaseConcurrentAuctionControllerBuilder<AnyRewardedAdDemandProvider, MediationObserverType> {
    
    override func providers(_ demands: [String]) -> [AnyAdapter: AnyRewardedAdDemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: RewardedAdDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                if let adapter = adapter {
                    let any = AnyAdapter(adapter: adapter)
                    result[any] = try adapter.rewardedAd().wrapped()
                }
            } catch {
                Logger.debug("Error while creating rewarded in adapter: \(adapter.debugDescription)")
            }
            
            return result
        }
    }
}


private extension RewardedAdDemandProvider {
    func wrapped() throws -> AnyRewardedAdDemandProvider {
        if self is DirectDemandProvider {
            return try AnyDirectDemandProvider(self)
        } else if self is ProgrammaticDemandProvider {
            return try AnyProgrammaticDemandProvider(self)
        } else {
            return try AnyDemandProvider(self)
        }
    }
}
