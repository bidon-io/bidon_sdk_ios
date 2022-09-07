//
//  MediationResultModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct MediationAttemptReportModel: MediationAttemptReport, Codable {
    struct DemandReportModel: DemandReport, Codable {
        var id: String
        var adUnitId: String?
        var format: String
        var status: DemandResult
        var startTimestamp: TimeInterval
        var finishTimestamp: TimeInterval
        
        init<T: DemandReport>(_ demand: T) {
            self.id = demand.id
            self.adUnitId = demand.adUnitId
            self.format = demand.format
            self.status = demand.status
            self.startTimestamp = demand.startTimestamp
            self.finishTimestamp = demand.finishTimestamp
        }
    }
    
    struct RoundReportModel: RoundReport, Codable {
        var id: String
        var pricefloor: Price
        var winnerPrice: Price?
        var winnerId: String?
        var demands: [DemandReportModel]
        
        init<T: RoundReport>(_ result: T) {
            self.id = result.id
            self.pricefloor = result.pricefloor
            self.winnerPrice = result.winnerPrice
            self.winnerId = result.winnerId
            self.demands = result.demands.map(DemandReportModel.init)
        }
    }
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [RoundReportModel]
    
    init<T: MediationAttemptReport>(_ result: T) {
        self.auctionId = result.auctionId
        self.auctionConfigurationId = result.auctionConfigurationId
        self.rounds = result.rounds.map(RoundReportModel.init)
    }
}
