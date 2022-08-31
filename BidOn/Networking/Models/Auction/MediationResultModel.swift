//
//  MediationResultModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct MediationResultModel: MediationResult, Codable {
    struct Demand: DemandResult, Codable {
        var id: String
        var adUnitId: String?
        var format: String
        var status: DemandMediationStatus
        var startTimestamp: TimeInterval
        var finishTimestamp: TimeInterval
        
        init<T: DemandResult>(_ demand: T) {
            self.id = demand.id
            self.adUnitId = demand.adUnitId
            self.format = demand.format
            self.status = demand.status
            self.startTimestamp = demand.startTimestamp
            self.finishTimestamp = demand.finishTimestamp
        }
    }
    
    struct Round: RoundResult, Codable {
        var id: String
        var pricefloor: Price
        var winnerPrice: Price
        var demands: [Demand]
        
        init<T: RoundResult>(_ result: T) {
            self.id = result.id
            self.pricefloor = result.pricefloor
            self.winnerPrice = result.winnerPrice
            self.demands = result.demands.map(Demand.init)
        }
    }
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [Round]
    
    init<T: MediationResult>(_ result: T) {
        self.auctionId = result.auctionId
        self.auctionConfigurationId = result.auctionConfigurationId
        self.rounds = result.rounds.map(Round.init)
    }
}
