//
//  AuctionRoundProtocol.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 01.07.2022.
//

import Foundation


typealias AuctionRoundDemandRequest = (Adapter, LineItem?) -> ()
typealias AuctionRoundDemandResult<T: DemandProvider> = Result<(T, DemandAd, LineItem?), MediationError>
typealias AuctionRoundDemandResponse<T: DemandProvider> = (Adapter, AuctionRoundDemandResult<T>) -> ()
typealias AuctionRoundCompletion = () -> ()


protocol AuctionRound {
    var id: String { get }
    var timeout: TimeInterval { get }
    var demands: [String] { get }
}


protocol PerformableAuctionRound: AuctionRound, Hashable {
    associatedtype DemandProviderType: DemandProvider
    
    var onDemandRequest: AuctionRoundDemandRequest? { get set }
    var onDemandResponse: AuctionRoundDemandResponse<DemandProviderType>? { get set }
    var onRoundComplete: AuctionRoundCompletion? { get set }
    
    func perform(pricefloor: Price)
    
    func cancel()
}
