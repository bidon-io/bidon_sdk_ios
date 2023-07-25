//
//  DefaultMediationAttemptReport.swift
//  Bidon
//
//  Created by Bidon Team on 08.09.2022.
//

import Foundation


struct MediationAttemptReportModel: MediationAttemptReport {
    typealias RoundReportType = RoundReportModel
    typealias AuctionResultReportType = AuctionResultReportModel
    
    var rounds: [RoundReportType]
    var result: AuctionResultReportModel
}


struct RoundReportModel: RoundReport {
    typealias DemandReportType = DemandReportModel
    
    var roundId: String
    var pricefloor: Price
    var winnerECPM: Price?
    var winnerNetworkId: String?
    var demands: [DemandReportType]
    var biddings: [DemandReportType]
}


struct AuctionResultReportModel: AuctionResultReport {
    var status: AuctionResultReportStatus
    var startTimestamp: UInt 
    var finishTimestamp: UInt
    var winnerNetworkId: String?
    var winnerECPM: Price?
    var winnerAdUnitId: String?
}


struct DemandReportModel: DemandReport {
    var networkId: String?
    var adUnitId: String? = nil
    var eCPM: Price?
    var status: DemandReportStatus = .unknown
    var bidStartTimestamp: UInt? = Date.timestamp(.wall, units: .milliseconds).uint
    var bidFinishTimestamp: UInt?
    var fillStartTimestamp: UInt?
    var fillFinishTimestamp: UInt?
}
