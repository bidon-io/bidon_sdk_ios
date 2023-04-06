//
//  AdvertisingService.swift
//  Sandbox
//
//  Created by Bidon Team on 13.02.2023.
//

import Foundation
import Bidon
import Combine


enum Mediation: String, CaseIterable {
    case none
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
    var isTestMode: Bool { get set }
    
    func initialize() async
    
    func adEventPublisher(adType: AdType) -> AnyPublisher<AdEventModel, Never>
    func adPublisher(adType: AdType) -> AnyPublisher<Bidon.Ad?, Never>
    
    func load(pricefloor: Double, adType: AdType) async throws
    
    func show(adType: AdType) async throws
    
    func notify(loss ad: Ad, adType: AdType)
}


protocol AdResponder {}


extension AdService {
    var bidOnURL: String {
        get { BidonSdk.baseURL }
        set { BidonSdk.baseURL = newValue }
    }
}

extension AdResponder {
    var adService: AdService {
        AdServiceProvider.shared.service
    }
}


extension Bidon.Logger.Level {
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
