//
//  AuctionControllerBuilder.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 06.07.2022.
//

import Foundation


class BaseConcurrentAuctionControllerBuilder<DemandProviderType>
where DemandProviderType: DemandProvider {
    
    typealias RoundType = ConcurrentAuctionRound<DemandProviderType>
    typealias AuctionType = Auction<RoundType>
    
    private(set) var comparator: AuctionComparator = HigherECPMAuctionComparator()
    private(set) var pricefloor: Price = .unknown
    private(set) var adaptersRepository: AdaptersRepository!
    private(set) var mediationObserver: AnyMediationObserver!
    private(set) var adRevenueObserver: AdRevenueObserver!
    private(set) var elector: LineItemElector!

    private var rounds: [AuctionRound] = []
    
    var auction: AuctionType {
        let concurentRounds: [RoundType] = rounds.map {
            RoundType(
                round: $0,
                elector: elector,
                adapters: adapters()
            )
        }
        
        var auction = AuctionType(rounds: concurentRounds)
        
        for idx in (0..<concurentRounds.count) {
            guard idx < (concurentRounds.count - 1) else { break }
            let current = concurentRounds[idx]
            let next = concurentRounds[idx + 1]
            try? auction.addEdge(from: current, to: next)
        }
        
        return auction
    }
    
    required init() {}
    
    open func adapters() -> [AnyDemandSourceAdapter<DemandProviderType>] {
        fatalError("BaseConcurrentAuctionControllerBuilder can't return adapters")
    }
    
    @discardableResult
    public func withComparator(_ comparator: AuctionComparator) -> Self {
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
        _ elector: LineItemElector
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
