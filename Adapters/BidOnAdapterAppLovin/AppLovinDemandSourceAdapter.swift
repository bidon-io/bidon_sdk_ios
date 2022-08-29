//
//  AppLovinDemandSourceAdapter.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import AppLovinSDK
import BidOn


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class AppLovinDemandSourceAdapter: NSObject, DemandSourceAdapter {
    public let identifier: String = "applovin"
    public let name: String = "AppLovin"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = ALSdk.version()
    
    private var sdk: ALSdk?
    
    public func interstitial() throws -> InterstitialDemandProvider {
        guard let sdk = self.sdk else {
            throw SdkError("AppLovin SDK is not initialized yet")
        }
        
        return AppLovinInterstitialDemandProvider(sdk: sdk)
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        guard let sdk = self.sdk else {
            throw SdkError("AppLovin SDK is not initialized yet")
        }
        
        return AppLovinRewardedDemandProvider(sdk: sdk)
    }
    
    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
        guard let sdk = self.sdk else {
            throw SdkError("AppLovin SDK is not initialized yet")
        }
        
        return AppLovinAdViewDemandProvider(sdk: sdk, context: context)
    }
}


extension AppLovinDemandSourceAdapter: InitializableAdapter {
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {
        var parameters: AppLovinParameters?
        
        do {
            parameters = try AppLovinParameters(from: decoder)
        } catch {
            completion(.failure(SdkError(error)))
        }
        
        let settings = ALSdkSettings()

        guard let parameters = parameters else { return }
        
        guard let sdk = ALSdk.shared(
            withKey: parameters.appKey,
            settings: settings
        ) else {
            completion(.failure(.message("Unable create sdk with app key: \(parameters.appKey)")))
            return
        }
        
        sdk.initializeSdk { configuration in
            completion(.success(()))
        }
        
        self.sdk = sdk
    }
}

