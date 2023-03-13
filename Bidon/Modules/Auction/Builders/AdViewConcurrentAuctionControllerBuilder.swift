//
//  AdViewConcurrentAuctionControllerBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 11.08.2022.
//

import Foundation


final class AdViewConcurrentAuctionControllerBuilder<MediationObserverType: MediationObserver>: BaseConcurrentAuctionControllerBuilder<AnyAdViewDemandProvider, MediationObserverType> {
    private var context: AdViewContext!
    
    @discardableResult
    public func withContext(_ context: AdViewContext) -> Self {
        self.context = context
        return self
    }
    
    override func adapters() -> [AnyDemandSourceAdapter<AnyAdViewDemandProvider>] {
        let adapters: [AdViewDemandSourceAdapter] = adaptersRepository.all()
        return adapters.compactMap { adapter in
            do {
                let provider = try adapter.adView(context).wrapped()
                return AnyDemandSourceAdapter(
                    adapter: adapter,
                    provider: provider
                )
            } catch {
                Logger.warning("Unable to create ad view demand provider for \(adapter), error: \(error)")
                return nil
            }
        }
    }
}


extension AdViewDemandProvider {
    func wrapped() throws -> AnyAdViewDemandProvider {
        switch self {
        case _ as any DirectDemandProvider:         return try AnyDirectDemandProvider(self)
        case _ as any ProgrammaticDemandProvider:   return try AnyProgrammaticDemandProvider(self)
        default:                                    return try AnyDemandProvider(self)
        }
    }
}
