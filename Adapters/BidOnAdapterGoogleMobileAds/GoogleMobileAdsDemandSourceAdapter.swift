//
//  GoogleMobileAdsDemandSourceAdapter.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import GoogleMobileAds
import BidOn


internal typealias DemandSourceAdapter = InitializableAdapter & InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc
public final class GoogleMobileAdsDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public static let identifier = "admob"
    
    public let identifier: String = GoogleMobileAdsDemandSourceAdapter.identifier
    public let name: String = "Google Mobile Ads"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = GADMobileAds.sharedInstance().sdkVersion
    
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {
        GADMobileAds.sharedInstance().start { _ in
            completion(.success(()))
        }
    }
    
    public func interstitial() throws -> InterstitialDemandProvider {
        return GoogleMobileAdsFullscreenDemandProvider<GADInterstitialAd>()
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        return GoogleMobileAdsFullscreenDemandProvider<GADRewardedAd>()
    }
    
    
    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
        return GoogleMobileAdsBannerDemandProvider(context: context)
    }
}

