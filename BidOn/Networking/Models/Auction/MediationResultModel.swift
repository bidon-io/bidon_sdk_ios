//
//  MediationResultModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct MediationResultModel: MediationLog, Codable {
    struct DemandResultModel: DemandLog, Codable {
        var id: String
        var adUnitId: String?
        var format: String
        var status: DemandResult
        var startTimestamp: TimeInterval
        var finishTimestamp: TimeInterval
        
        init<T: DemandLog>(_ demand: T) {
            self.id = demand.id
            self.adUnitId = demand.adUnitId
            self.format = demand.format
            self.status = demand.status
            self.startTimestamp = demand.startTimestamp
            self.finishTimestamp = demand.finishTimestamp
        }
    }
    
    struct RoundResultModel: RoundLog, Codable {
        var id: String
        var pricefloor: Price
        var winnerPrice: Price
        var demands: [DemandResultModel]
        
        init<T: RoundLog>(_ result: T) {
            self.id = result.id
            self.pricefloor = result.pricefloor
            self.winnerPrice = result.winnerPrice
            self.demands = result.demands.map(DemandResultModel.init)
        }
    }
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [RoundResultModel]
    
    init<T: MediationLog>(_ result: T) {
        self.auctionId = result.auctionId
        self.auctionConfigurationId = result.auctionConfigurationId
        self.rounds = result.rounds.map(RoundResultModel.init)
    }
}
