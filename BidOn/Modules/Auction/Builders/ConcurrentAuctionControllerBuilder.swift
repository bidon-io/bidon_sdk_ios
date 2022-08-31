//
//  AuctionControllerBuilder.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation


protocol ConcurrentAuctionControllerBuilder: BaseConcurrentAuctionControllerBuilder {
    var adType: AdType { get }
    
    init()
}


class BaseConcurrentAuctionControllerBuilder {
    private(set) var comparator: AuctionComparator = HigherPriceAuctionComparator()
    private(set) var delegate: AuctionControllerDelegate?
    private(set) var pricefloor: Price = .unknown
    private(set) var adaptersRepository: AdaptersRepository!
    private(set) var auctionId: String = ""
    private(set) var auctionConfigurationId: Int = 0
    
    private var rounds: [AuctionRound] = []
    private var lineItems: LineItems = []
    
    var auction: ConcurrentAuction {
        let concurentRounds: [ConcurrentAuctionRound] = rounds.map {
            ConcurrentAuctionRound(
                round: $0,
                lineItems: lineItems,
                providers: providers($0.demands)
            )
        }
        
        var auction = ConcurrentAuction(rounds: concurentRounds)
        
        for idx in (0..<concurentRounds.count) {
            guard idx < (concurentRounds.count - 1) else { break }
            let current = concurentRounds[idx]
            let next = concurentRounds[idx + 1]
            try? auction.addEdge(from: current, to: next)
        }
        
        return auction
    }
    
    open func providers(_ demands: [String]) -> [String: DemandProvider] {
        return [:]
    }
    
    @discardableResult
    public func withComparator(_ comparator: AuctionComparator) -> Self {
        self.comparator = comparator
        return self
    }
    
    @discardableResult
    public func withDelegate(_ delegate: AuctionControllerDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    public func withRounds(
        _ rounds: [AuctionRound],
        lineItems: LineItems
    ) -> Self {
        self.rounds = rounds
        self.lineItems = lineItems
        return self
    }
    
    @discardableResult
    public func withAuctionId(
        _ auctionId: String
    ) -> Self {
        self.auctionId = auctionId
        return self
    }
    
    @discardableResult
    public func withAuctionConfigurationId(
        _ auctionConfigurationId: Int
    ) -> Self {
        self.auctionConfigurationId = auctionConfigurationId
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
