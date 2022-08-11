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
    private(set) var resolver: AuctionResolver = HigherRevenueAuctionResolver()
    private(set) var delegate: AuctionControllerDelegate?
    private(set) var pricefloor: Price = .unknown
    private(set) var adaptersRepository: AdaptersRepository!

    private var rounds: [AuctionRound] = []
    private var lineItems: LineItems = []
    
    var auction: ConcurrentAuction {
        return ConcurrentAuction(
            rounds: rounds.map {
                ConcurrentAuctionRound(
                    round: $0,
                    lineItems: lineItems,
                    providers: providers($0.demands)
                )
            }
        )
    }
    
    open func providers(_ demands: [String]) -> [String: DemandProvider] {
        return [:]
    }
    
    @discardableResult
    public func withResolver(_ resolver: AuctionResolver) -> Self {
        self.resolver = resolver
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
