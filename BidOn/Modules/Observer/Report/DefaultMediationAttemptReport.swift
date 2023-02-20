//
//  DefaultMediationAttemptReport.swift
//  BidOn
//
//  Created by Stas Kochkin on 08.09.2022.
//

import Foundation


struct DefaultMediationAttemptReport: MediationAttemptReport {
    typealias RoundReportType = DefaultRoundReport
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [RoundReportType]
}


struct DefaultRoundReport: RoundReport {
    typealias DemandReportType = DefaultDemandReport
    
    var roundId: String
    var pricefloor: Price
    var winnerPrice: Price?
    var winnerNetworkId: String?
    var demands: [DemandReportType]
}


struct DefaultDemandReport: DemandReport {
    var networkId: String
    var adUnitId: String? = nil
    var price: Price
    var status: DemandResult = .unknown
    var bidStartTimestamp: UInt? = Date.timestamp(.wall, units: .milliseconds).uint
    var bidFinishTimestamp: UInt?
    var fillStartTimestamp: UInt?
    var fillFinishTimestamp: UInt?
}
