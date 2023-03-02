//
//  AppLovinDemandSourceAdapter.swift
//  BidonAdapterAppLovin
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import AppLovinSDK
import AdSupport
import Bidon


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class AppLovinDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public static let identifier = "applovin"
    
    public let identifier: String = AppLovinDemandSourceAdapter.identifier
    public let name: String = "AppLovin"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = ALSdk.version()
    
    @Injected(\.context)
    var context: AuctionContext
    
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
    private struct Parameters: Codable {
        public var appKey: String
    }
    
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {
        var parameters: Parameters?
        
        do {
            parameters = try Parameters(from: decoder)
        } catch {
            completion(.failure(SdkError(error)))
        }
        
        let settings = ALSdkSettings()
        
        guard let parameters = parameters else { return }
        
        settings.testDeviceAdvertisingIdentifiers = context.isTestMode ?
        [ASIdentifierManager.shared().advertisingIdentifier.uuidString] :
        []
        
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

