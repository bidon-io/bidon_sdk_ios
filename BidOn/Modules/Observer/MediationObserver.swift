//
//  MediationObserver.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


final class MediationObserver: MediationResult {
    struct DemandResulttObservationInfo: DemandResult {
        var id: String
        var adUnitId: String?
        var format: String
        var status: DemandMediationStatus
        var startTimestamp: TimeInterval
        var finishTimestamp: TimeInterval
    }
    
    struct RoundResultObservationInfo: RoundResult {
        typealias DemandResultType = DemandResulttObservationInfo
        
        var id: String
        var pricefloor: Price
        var winnerPrice: Price
        var demands: [MediationObserver.DemandResulttObservationInfo]
    }
    
    let auctionId: String
    let auctionConfigurationId: Int
    
    private(set) var rounds: [RoundResultObservationInfo] = []
    
    init(id: String, configurationId: Int) {
        self.auctionId = id
        self.auctionConfigurationId = configurationId
    }
}
