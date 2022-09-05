//
//  MediationResult.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


enum DemandResult: UInt, Codable {
    case win = 1
    case lose = 2
    case noBid = 3
    case noFill = 4
    case unknownAdapter = 5
    case adapterNotInitialized = 6
    case bidTimeoutReached = 7
    case fillTiemoutReached = 8
    case networkError = 9
    case incorrectAdUnitId = 10
    case noApproperiateAdUnitId = 11
    case auctionCancelled = 12
    case adFormatNotSupported = 13
    case unscpecifiedException = 14
}


protocol DemandLog {
    var id: String { get }
    var adUnitId: String? { get }
    var format: String { get }
    var status: DemandResult { get }
    var startTimestamp: TimeInterval { get }
    var finishTimestamp: TimeInterval { get }
}


protocol RoundLog {
    associatedtype DemandLogType: DemandLog
    
    var id: String { get }
    var pricefloor: Price { get }
    var winnerPrice: Price { get }
    var demands: [DemandLogType] { get }
}


protocol MediationLog {
    associatedtype RoundLogType: RoundLog
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var rounds: [RoundLogType] { get }
}



