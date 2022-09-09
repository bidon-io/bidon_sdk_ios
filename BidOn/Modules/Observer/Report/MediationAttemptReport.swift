//
//  MediationResult.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


enum DemandResult: String, Codable {
    case unknown
    case win
    case lose
    case noBid
    case noFill
    case unknownAdapter
    case adapterNotInitialized
    case bidTimeoutReached
    case fillTiemoutReached
    case networkError
    case incorrectAdUnitId
    case noApproperiateAdUnitId
    case auctionCancelled
    case adFormatNotSupported
    case unscpecifiedException
    case belowPricefloor
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue.camelCaseToSnakeCase().uppercased())
    }
}


protocol DemandReport {
    var networkId: String { get }
    var adUnitId: String? { get }
    var status: DemandResult { get }
    var price: Price { get }
    var bidStartTimestamp: TimeInterval { get }
    var bidFinishTimestamp: TimeInterval { get }
    var fillStartTimestamp: TimeInterval { get }
    var fillFinishTimestamp: TimeInterval { get }
}


protocol RoundReport {
    associatedtype DemandReportType: DemandReport
    
    var roundId: String { get }
    var pricefloor: Price { get }
    var winnerPrice: Price? { get }
    var winnerNetworkId: String? { get }
    var demands: [DemandReportType] { get }
}


protocol MediationAttemptReport {
    associatedtype RoundReportType: RoundReport
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var rounds: [RoundReportType] { get }
}



