//
//  MediationResult.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


protocol DemandReport {
    var networkId: String { get }
    var adUnitId: String? { get }
    var status: DemandResult { get }
    var eCPM: Price { get }
    var bidStartTimestamp: UInt? { get }
    var bidFinishTimestamp: UInt? { get }
    var fillStartTimestamp: UInt? { get }
    var fillFinishTimestamp: UInt? { get }
}


protocol RoundReport {
    associatedtype DemandReportType: DemandReport
    
    var roundId: String { get }
    var pricefloor: Price { get }
    var winnerECPM: Price? { get }
    var winnerNetworkId: String? { get }
    var demands: [DemandReportType] { get }
}


protocol MediationAttemptReport {
    associatedtype RoundReportType: RoundReport
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var rounds: [RoundReportType] { get }
}



