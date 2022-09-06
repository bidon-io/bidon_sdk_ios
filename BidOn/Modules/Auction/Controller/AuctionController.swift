//
//  AuctionControllerDelegate.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation


enum DemandEvent<DemandProviderType: DemandProvider> {
    case didStartAuction
    case didStartRound(round: AuctionRound, pricefloor: Price)
    case didReceiveBid(bid: Bid<DemandProviderType>)
    case didCompleteRound(round: AuctionRound)
}


protocol AuctionController {
    associatedtype DemandProviderType: DemandProvider
    associatedtype DemandType: Demand where DemandType.Provider == DemandProviderType
    
    typealias WaterfallType = Waterfall<DemandType>
    typealias DemandEventType = DemandEvent<DemandProviderType>
    
    typealias Completion = (Result<WaterfallType, SdkError>) -> ()
    typealias DemandEventHandler = (DemandEventType) -> ()
    
    var eventHandler: DemandEventHandler? { get set }
    
    func load(completion: @escaping Completion)
}
