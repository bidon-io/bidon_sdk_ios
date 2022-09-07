//
//  AuctionRoundProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation


typealias AuctionRoundBidRequest = (Adapter, LineItem?) -> ()
typealias AuctionRoundBidResult<T: DemandProvider> = Result<Bid<T>, MediationError>
typealias AuctionRoundBidResponse<T: DemandProvider> = (Adapter, AuctionRoundBidResult<T>) -> ()
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
        request: @escaping AuctionRoundBidRequest,
        response: @escaping AuctionRoundBidResponse<DemandProviderType>,
        completion: @escaping AuctionRoundCompletion
    )
    
    func timeoutReached()
    func destroy()
}
