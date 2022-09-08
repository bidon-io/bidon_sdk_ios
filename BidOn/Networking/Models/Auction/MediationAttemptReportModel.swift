//
//  MediationResultModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct MediationAttemptReportModel: MediationAttemptReport, Codable {
    struct DemandReportModel: DemandReport, Codable {
        var networkId: String
        var adUnitId: String?
        var status: DemandResult
        var price: Price
        var bidStartTimestamp: TimeInterval
        var bidFinishTimestamp: TimeInterval
        var fillStartTimestamp: TimeInterval
        var fillFinishTimestamp: TimeInterval
        
        init<T: DemandReport>(_ report: T) {
            self.networkId = report.networkId
            self.adUnitId = report.adUnitId
            self.status = report.status
            self.price = report.price
            self.bidStartTimestamp = report.bidStartTimestamp
            self.bidFinishTimestamp = report.bidFinishTimestamp
            self.fillStartTimestamp = report.fillStartTimestamp
            self.fillFinishTimestamp = report.fillFinishTimestamp
        }
        
        enum CodingKeys: String, CodingKey {
            case networkId = "id"
            case adUnitId = "ad_unit_id"
            case status
            case price = "ecpm"
            case bidStartTimestamp = "bid_start_ts"
            case bidFinishTimestamp = "bid_finish_ts"
            case fillStartTimestamp = "fill_start_ts"
            case fillFinishTimestamp = "fill_finish_ts"
        }
    }
    
    struct RoundReportModel: RoundReport, Codable {
        var roundId: String
        var pricefloor: Price
        var winnerPrice: Price?
        var winnerNetworkId: String?
        var demands: [DemandReportModel]
        
        init<T: RoundReport>(_ report: T) {
            self.roundId = report.roundId
            self.pricefloor = report.pricefloor
            self.winnerPrice = report.winnerPrice
            self.winnerNetworkId = report.winnerNetworkId
            self.demands = report.demands.map(DemandReportModel.init)
        }
        
        enum CodingKeys: String, CodingKey {
            case roundId = "id"
            case pricefloor
            case winnerPrice = "winner_ecpm"
            case winnerNetworkId = "winner_id"
            case demands
        }
    }
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [RoundReportModel]
    
    init<T: MediationAttemptReport>(_ report: T) {
        self.auctionId = report.auctionId
        self.auctionConfigurationId = report.auctionConfigurationId
        self.rounds = report.rounds.map(RoundReportModel.init)
    }
}
