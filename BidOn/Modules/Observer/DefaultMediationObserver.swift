//
//  MediationObserver.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


final class DefaultMediationObserver: MediationObserver {
    struct ObservationData: MediationLog {
        typealias RoundLogType = RoundObservationData

        var auctionId: String
        var auctionConfigurationId: Int
        var rounds: [RoundObservationData]
    }
    
    struct RoundObservationData: RoundLog {
        typealias DemandLogType = DemandObservationData
        
        var id: String
        var pricefloor: Price
        var winnerPrice: Price
        var demands: [DemandObservationData]
    }
    
    struct DemandObservationData: DemandLog {
        var id: String
        var adUnitId: String?
        var format: String
        var status: DemandResult
        var startTimestamp: TimeInterval
        var finishTimestamp: TimeInterval
    }

    
    let auctionId: String
    let auctionConfigurationId: Int
    
    var log: ObservationData {
        .init(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            rounds: []
        )
    }
    
    init(id: String, configurationId: Int) {
        self.auctionId = id
        self.auctionConfigurationId = configurationId
    }
}
