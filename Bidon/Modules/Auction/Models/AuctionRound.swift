//
//  AuctionRoundProtocol.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 01.07.2022.
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
    
    var onDemandRequest: AuctionRoundBidRequest? { get set }
    var onDemandResponse: AuctionRoundBidResponse<DemandProviderType>? { get set }
    var onRoundComplete: AuctionRoundCompletion? { get set }
    
    func perform(pricefloor: Price)
    
    func cancel()
}
