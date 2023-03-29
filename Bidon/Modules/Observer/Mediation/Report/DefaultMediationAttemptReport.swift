//
//  DefaultMediationAttemptReport.swift
//  Bidon
//
//  Created by Bidon Team on 08.09.2022.
//

import Foundation


struct DefaultMediationAttemptReport: MediationAttemptReport {
    typealias RoundReportType = DefaultRoundReport
    typealias AuctionResultReportType = DefaultAuctionResultReport
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [RoundReportType]
    var result: DefaultAuctionResultReport
}


struct DefaultRoundReport: RoundReport {
    typealias DemandReportType = DefaultDemandReport
    
    var roundId: String
    var pricefloor: Price
    var winnerECPM: Price?
    var winnerNetworkId: String?
    var demands: [DemandReportType]
}


struct DefaultAuctionResultReport: AuctionResultReport {
    var status: AuctionResultStatus
    var winnerNetworkId: String?
    var winnerECPM: Price?
    var winnerAdUnitId: String?
}

struct DefaultDemandReport: DemandReport {
    var networkId: String
    var adUnitId: String? = nil
    var eCPM: Price
    var status: DemandResultStatus = .unknown
    var bidStartTimestamp: UInt? = Date.timestamp(.wall, units: .milliseconds).uint
    var bidFinishTimestamp: UInt?
    var fillStartTimestamp: UInt?
    var fillFinishTimestamp: UInt?
}
