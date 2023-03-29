//
//  InterstitialConcurrentAuctionControllerBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 11.08.2022.
//

import Foundation


final class InterstitialConcurrentAuctionControllerBuilder: BaseConcurrentAuctionControllerBuilder<AnyInterstitialDemandProvider> {
    override func adapters() -> [AnyDemandSourceAdapter<AnyInterstitialDemandProvider>] {
        let adapters: [InterstitialDemandSourceAdapter] = adaptersRepository.all()
        return adapters.compactMap { adapter in
            do {
                let provider = try adapter.interstitial().wrapped()
                return AnyDemandSourceAdapter(
                    adapter: adapter,
                    provider: provider
                )
            } catch {
                Logger.warning("Unable to create interstitial demand provider for \(adapter), error: \(error)")
                return nil
            }
        }
    }
}


private extension InterstitialDemandProvider {
    func wrapped() throws -> AnyInterstitialDemandProvider {
        switch self {
        case _ as any DirectDemandProvider:         return try DirectDemandProviderWrapper(self)
        case _ as any ProgrammaticDemandProvider:   return try ProgrammaticDemandProviderWrapper(self)
        default:                                    return try DemandProviderWrapper(self)
        }
    }
}
