//
//  SDK.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 15.06.2022.
//

import Foundation
import UIKit


@objc public final class SDK: NSObject {
    private var repository = AdaptersRepository()
    
    @objc public var adapters: [Adapter] {
        return repository.all()
    }
    
    @objc public func register(adapter: Adapter) throws {
        repository.register(adapter)
    }
    
    public func register<T: ParameterizedAdapter>(adapter: T.Type, parameters: T.Parameters) {
        let adapter = adapter.init(parameters: parameters)
        repository.register(adapter)
    }
    
    @objc public func initialize(completion: @escaping () -> ()) {
        let initializable: [InitializableAdapter] = repository.all()
        let group = DispatchGroup()
        initializable.forEach {
            group.enter()
            $0.initilize { _ in group.leave() }
        }
        group.notify(queue: .main, execute: completion)
    }
    
    public func trackAdRevenue(
        _ ad: Ad,
        mediation: Mediation,
        auctionRound: String,
        adType: AdType
    ) {
        let mmps: [MobileMeasurementPartnerAdapter] = repository.all()
        mmps.forEach {
            $0.trackAdRevenue(
                ad,
                mediation: mediation,
                auctionRound: auctionRound,
                adType: adType
            )
        }
    }
}


public extension SDK {
    func interstitialDemandProviders() -> [InterstitialDemandProvider] {
        let sources: [InterstitialDemandSourceAdapter] = repository.all()
        return sources.compactMap { try? $0.interstitial() }
    }
    
    func rewardedAdDemandProviders() -> [RewardedAdDemandProvider] {
        let sources: [RewardedAdDemandSourceAdapter] = repository.all()
        return sources.compactMap { try? $0.rewardedAd() }
    }
    
    func adViewDemandProviders(_ context: AdViewContext) -> [AdViewDemandProvider] {
        let sources: [AdViewDemandSourceAdapter] = repository.all()
        return sources.compactMap { try? $0.adView(context) }
    }
}
