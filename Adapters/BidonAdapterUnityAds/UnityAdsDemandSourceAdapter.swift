//
//  BidonAdapterUnityAds.swift
//  BidonAdapterUnityAds
//
//  Created by Bidon Team on 01.03.2023.
//

import Foundation
import UnityAds
import Bidon


internal typealias DemandSourceAdapter = DirectInterstitialDemandSourceAdapter &
DirectRewardedAdDemandSourceAdapter &
DirectAdViewDemandSourceAdapter


@objc public final class UnityAdsDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public static let identifier = "unityads"

    @Injected(\.context)
    var context: Bidon.SdkContext

    public let demandId: String = UnityAdsDemandSourceAdapter.identifier
    public let name: String = "Unity Ads"
    public let adapterVersion: String = "0"
    public let sdkVersion: String = UnityAds.getVersion()

    private var completion: ((SdkError?) -> Void)?

    public func directInterstitialDemandProvider () throws -> AnyDirectInterstitialDemandProvider {
        return UnityAdsInterstitialDemandProvider()
    }

    public func directRewardedAdDemandProvider() throws -> AnyDirectRewardedAdDemandProvider {
        return UnityAdsInterstitialDemandProvider()
    }

    public func directAdViewDemandProvider(context: AdViewContext) throws -> AnyDirectAdViewDemandProvider {
        return UnityAdsBannerDemandProvider(context: context)
    }
}


extension UnityAdsDemandSourceAdapter: ParameterizedInitializableAdapter {
    public var isInitialized: Bool {
        return UnityAds.isInitialized()
    }

    public func initialize(
        parameters: UnityAdsParameters,
        completion: @escaping (SdkError?) -> Void
    ) {
        self.completion = completion

        UnityAds.initialize(
            parameters.gameId,
            testMode: context.isTestMode,
            initializationDelegate: self
        )
    }
}


extension UnityAdsDemandSourceAdapter: UnityAdsInitializationDelegate {
    public func initializationComplete() {
        completion?(nil)
        completion = nil
    }

    public func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        completion?(.message(message))
        completion = nil
    }
}
