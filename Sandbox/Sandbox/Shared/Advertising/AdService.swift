//
//  AdvertisingService.swift
//  Sandbox
//
//  Created by Stas Kochkin on 13.02.2023.
//

import Foundation
import BidOn
import Combine


enum Mediation: String {
    case appodeal
}


enum AdType {
    case banner
    case interstitial
    case rewardedAd
}


enum LogLevel: String, CaseIterable {
    case verbose
    case debug
    case info
    case warning
    case error
    case off
}


protocol AdService: AnyObject {
    var mediation: Mediation { get }
    
    var verstion: String { get }
    
    var logLevel: LogLevel { get set }
    
    func initialize() async
    
    func adEventPublisher(adType: AdType) -> AnyPublisher<AdEventModel, Never>
    
    func load(pricefloor: Double, adType: AdType) async throws
    
    func show(adType: AdType) async throws
}


protocol AdResponder {}


extension AdService {
    var bidOnURL: String {
        get { BidOnSdk.baseURL }
        set { BidOnSdk.baseURL = newValue }
    }
}

extension AdResponder {
    var adService: AdService {
        AdverstisingServiceProvider.shared.service
    }
}


extension BidOn.Logger.Level {
    init(_ level: LogLevel) {
        switch level {
        case .verbose: self = .verbose
        case .debug: self = .debug
        case .info: self = .info
        case .warning: self = .warning
        case .error: self = .error
        case .off: self = .off
        }
    }
}
