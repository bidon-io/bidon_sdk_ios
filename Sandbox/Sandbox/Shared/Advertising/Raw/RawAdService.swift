//
//  RawAdService.swift
//  Sandbox
//
//  Created by Stas Kochkin on 16.02.2023.
//

import Foundation
import Foundation
import Combine
import BidOn


enum RawAdServiceError: Error {
    case unsupported
    case noFill
    case invalidPresentationState
}


final class RawAdService: NSObject, AdService {
    var mediation: Mediation { .none }
    
    var verstion: String { "-" }
    
    var logLevel: LogLevel = .debug {
        didSet {
            BidOnSdk.logLevel = BidOn.Logger.Level(logLevel)
        }
    }
    
    private lazy var interstitial = RawInterstitialAdWrapper()
    private lazy var rewardedAd = RawRewardedAdWrapper()
    
    override init() {
        super.init()
        BidOnSdk.logLevel = BidOn.Logger.Level(.debug)
    }
    
    func initialize() async {
        await withCheckedContinuation { continuation in
            BidOnSdk.initialize(appKey: Constants.BidOn.appKey) {
                continuation.resume()
            }
        }
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

