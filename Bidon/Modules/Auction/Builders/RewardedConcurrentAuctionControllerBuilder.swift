//
//  RewardedConcurrentAuctionControllerBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 11.08.2022.
//

import Foundation


final class RewardedConcurrentAuctionControllerBuilder<MediationObserverType: MediationObserver>: BaseConcurrentAuctionControllerBuilder<AnyRewardedAdDemandProvider, MediationObserverType> {
    
    override func adapters() -> [AnyDemandSourceAdapter<AnyRewardedAdDemandProvider>] {
        let adapters: [RewardedAdDemandSourceAdapter] = adaptersRepository.all()
        return adapters.compactMap { adapter in
            do {
                let provider = try adapter.rewardedAd().wrapped()
                return AnyDemandSourceAdapter(
                    adapter: adapter,
                    provider: provider
                )
            } catch {
                Logger.warning("Unable to create rewarded ad demand provider for \(adapter), error: \(error)")
                return nil
            }
        }
    }
}


private extension RewardedAdDemandProvider {
    func wrapped() throws -> AnyRewardedAdDemandProvider {
        switch self {
        case _ as any DirectDemandProvider:         return try AnyDirectDemandProvider(self)
        case _ as any ProgrammaticDemandProvider:   return try AnyProgrammaticDemandProvider(self)
        default:                                    return try AnyDemandProvider(self)
        }
    }
}
