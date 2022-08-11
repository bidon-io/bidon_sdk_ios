//
//  AuctionRoundProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation

typealias Demand = (ad: Ad, provider: DemandProvider)
typealias AuctionRoundDemandResponse = (Result<Demand, SdkError>) -> ()
typealias AuctionRoundCompletion = () -> ()


protocol AuctionRound {
    var id: String { get }
    var timeout: TimeInterval { get }
    var demands: [String] { get }
}


protocol PerformableAuctionRound: AuctionRound, Hashable {
    func perform(
        pricefloor: Price,
        demand: @escaping AuctionRoundDemandResponse,
        completion: @escaping AuctionRoundCompletion
    )
    
    func cancel()
}
