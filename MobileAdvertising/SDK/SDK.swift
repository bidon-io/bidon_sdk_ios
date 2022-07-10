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
