//
//  AuctionRoundProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation

typealias AuctionRoundDemand = (Ad, DemandProvider) -> ()
typealias AuctionRoundCompletion = () -> ()


public protocol AuctionRound {
    var id: String { get }
    var providers: [DemandProvider] { get }
}


protocol PerformableAuctionRound: AuctionRound, Hashable {
    func perform(
        pricefloor: Price,
        demand: @escaping AuctionRoundDemand,
        completion: @escaping AuctionRoundCompletion
    )
    
    func cancel()
}
