//
//  AuctionRoundProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation


typealias AuctionRoundBidResponse<DemandProviderType: DemandProvider> = (Result<Bid<DemandProviderType>, SdkError>) -> ()
typealias AuctionRoundCompletion = () -> ()


protocol AuctionRound {
    var id: String { get }
    var timeout: TimeInterval { get }
    var demands: [String] { get }
}


protocol PerformableAuctionRound: AuctionRound, Hashable {
    associatedtype DemandProviderType: DemandProvider
    
    func perform(
        pricefloor: Price,
        bid: @escaping AuctionRoundBidResponse<DemandProviderType>,
        completion: @escaping AuctionRoundCompletion
    )
    
    func cancel()
}
