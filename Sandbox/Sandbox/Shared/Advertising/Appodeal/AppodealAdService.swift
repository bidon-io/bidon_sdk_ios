//
//  AppodealAdvertisingService.swift
//  Sandbox
//
//  Created by Bidon Team on 13.02.2023.
//

import Foundation
import Appodeal
import Combine
import Bidon


enum AppodealAdServiceError: Error {
    case unsupported
    case noFill
    case invalidPresentationState
}


protocol AppodealAdInitializationWrapper {
    func initialize(appKey: String, adTypes: AppodealAdType) async
}


final class AppodealAdService: NSObject, AdService {
    var mediation: Mediation { .appodeal }
    
    var verstion: String { APDSdkVersionString() }
    
    var logLevel: LogLevel = .debug {
        didSet {
            Appodeal.setLogLevel(APDLogLevel(logLevel))
            BidonSdk.logLevel = Bidon.Logger.Level(logLevel)
        }
    }
    
    override init() {
        super.init()
        Appodeal.setActivityDelegate(self)
        Appodeal.setAdRevenueDelegate(self)
        
        Appodeal.setLogLevel(APDLogLevel(.debug))
        BidonSdk.logLevel = Bidon.Logger.Level(.debug)
    }
    
    private lazy var initializator = AppodealDefaultAdInitializationWrapper()
    private lazy var interstitial = AppodealInterstitialAdWrapper()
    private lazy var rewardedAd = AppodealRewardedAdWrapper()
    
    func initialize() async {
        await initializator.initialize(
            appKey: Constants.Appodeal.appKey,
            adTypes: [.banner, .interstitial, .rewardedVideo]
        )
    }
    
    func adEventPublisher(adType: AdType) -> AnyPublisher<AdEventModel, Never> {
        switch adType {
        case .interstitial: return interstitial.adEventSubject.eraseToAnyPublisher()
        case .rewardedAd: return rewardedAd.adEventSubject.eraseToAnyPublisher()
        default: fatalError("Not implemented")
        }
    }
    
    func load(pricefloor: Double, adType: AdType) async throws {
        switch adType {
        case .interstitial: try await interstitial.load(pricefloor: pricefloor)
        case .rewardedAd: try await rewardedAd.load(pricefloor: pricefloor)
        default: throw AppodealAdServiceError.unsupported
        }
    }
    
    func show(adType: AdType) async throws {
        switch adType {
        case .interstitial: try await interstitial.show()
        case .rewardedAd: try await rewardedAd.show()
        default: throw AppodealAdServiceError.unsupported
        }
    }
}


extension AppodealAdService: APDActivityDelegate {
    func didReceive(_ activityLog: APDActivityLog) {
        var receiver: AdWrapper?
        
        switch activityLog.adType {
        case .interstitialAd: receiver = interstitial
        case .rewardedVideo: receiver = rewardedAd
        default: break
        }
        
        receiver?.send(
            event: activityLog.activityType.text,
            detail: "Ad Network: \(activityLog.adNetwork). \(activityLog.message ?? "")",
            bage: "drop.fill",
            color: .accentColor
        )
    }
}


extension AppodealAdService: AppodealAdRevenueDelegate {
    func didReceiveRevenue(forAd ad: AppodealAdRevenue) {
        var receiver: AdWrapper?
        
        switch ad.adType {
        case .interstitial: receiver = interstitial
        case .rewardedVideo: receiver = rewardedAd
        default: break
        }
        
        receiver?.send(
            event: "Appodeal did pay revenue",
            detail: ad.description,
            bage: "cart.fill",
            color: .primary
        )
    }
}



