//
//  AdViewConcurrentAuctionControllerBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class AdViewConcurrentAuctionControllerBuilder<MediationObserverType: MediationObserver>: BaseConcurrentAuctionControllerBuilder<AnyAdViewDemandProvider, MediationObserverType> {
    override var adType: AdType { .banner }
    
    private var context: AdViewContext!
    
    @discardableResult
    public func withContext(_ context: AdViewContext) -> Self {
        self.context = context
        return self
    }
    
    override func providers(_ demands: [String]) -> [String: AnyAdViewDemandProvider] {
        demands.reduce([:]) { result, id in
            var result = result
            let adapter: AdViewDemandSourceAdapter? = adaptersRepository[id]
            
            do {
                if let provider = try adapter?.adView(context) {
                    result[id] = try provider.wrapped()
                }
            } catch {
                Logger.debug("Error while creating banner in adapter: \(adapter.debugDescription)")
            }
            
            return result
        }
    }
}


extension AdViewDemandProvider {
    func wrapped() throws -> AnyAdViewDemandProvider {
        if self is DirectDemandProvider {
            return try AnyDirectDemandProvider(self)
        } else if self is ProgrammaticDemandProvider {
            return try AnyProgrammaticDemandProvider(self)
        } else {
            return try AnyDemandProvider(self)
        }
    }
}
