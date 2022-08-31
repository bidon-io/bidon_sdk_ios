//
//  MediationResult.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation

#warning("Do something with oberver")
enum DemandMediationStatus: String, Codable {
    case successful
    case noFill
    case timeout
    case exception
    case undefinedAdapter
    case incorrectAdUnit
    case invalidAssets
    case cancelled
}


protocol DemandResult {
    var id: String { get }
    var adUnitId: String? { get }
    var format: String { get }
    var status: DemandMediationStatus { get }
    var startTimestamp: TimeInterval { get }
    var finishTimestamp: TimeInterval { get }
}


protocol RoundResult {
    associatedtype DemandResultType: DemandResult
    
    var id: String { get }
    var pricefloor: Price { get }
    var winnerPrice: Price { get }
    var demands: [DemandResultType] { get }
}


protocol MediationResult {
    associatedtype RoundResultType: RoundResult
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var rounds: [RoundResultType] { get }
}



