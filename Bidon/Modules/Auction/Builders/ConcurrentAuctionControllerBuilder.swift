//
//  AuctionControllerBuilder.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 06.07.2022.
//

import Foundation


class BaseConcurrentAuctionControllerBuilder<DemandProviderType>
where DemandProviderType: DemandProvider {
    private(set) var comparator: AuctionBidComparator = HigherECPMAuctionBidComparator()
    private(set) var pricefloor: Price = .unknown
    private(set) var adaptersRepository: AdaptersRepository!
    private(set) var mediationObserver: AnyMediationObserver!
    private(set) var adRevenueObserver: AdRevenueObserver!
    private(set) var elector: AuctionLineItemElector!
    
    private(set) var rounds: [AuctionRound] = []
    
    required init() {}
    
    open func adapters() -> [AnyDemandSourceAdapter<DemandProviderType>] {
        fatalError("BaseConcurrentAuctionControllerBuilder can't return adapters")
    }
    
    @discardableResult
    public func withComparator(_ comparator: AuctionBidComparator) -> Self {
        self.comparator = comparator
        return self
    }
    
    @discardableResult
    public func withRounds(
        _ rounds: [AuctionRound]
    ) -> Self {
        self.rounds = rounds
        return self
    }
    
    @discardableResult
    public func withElector(
        _ elector: AuctionLineItemElector
    ) -> Self {
        self.elector = elector
        return self
    }
    
    @discardableResult
    public func withMediationObserver(
        _ observer: AnyMediationObserver
    ) -> Self {
        self.mediationObserver = observer
        return self
    }
    
    @discardableResult
    public func withAdRevenueObserver(
        _ observer: AdRevenueObserver
    ) -> Self {
        self.adRevenueObserver = observer
        return self
    }
    
    @discardableResult
    public func withPricefloor(_ pricefloor: Price) -> Self {
        self.pricefloor = pricefloor
        return self
    }
    
    @discardableResult
    public func withAdaptersRepository(_ repository: AdaptersRepository) -> Self {
        self.adaptersRepository = repository
        return self
    }
}
