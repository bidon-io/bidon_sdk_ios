//
//  GoogleMobileAdsDemandSourceAdapter.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import GoogleMobileAds
import BidOn


internal typealias DemandSourceAdapter = InitializableAdapter & InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter // & AdViewDemandSourceAdapter


@objc
public final class GoogleMobileAdsDemandSourceAdapter: NSObject, DemandSourceAdapter {
    public let identifier: String = "admob"
    public let name: String = "Google Mobile Ads"
    public let version: String = "1"
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
        GoogleMobileAdsFullscreenDemandProvider<GADInterstitialAd>()
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        GoogleMobileAdsFullscreenDemandProvider<GADRewardedAd>()
    }
    
    
    //    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
    //        GoogleMobileAdsBannerDemandProvider(context: context) { [weak self] price in
    //            return self?.parameters.lineItems.banner?.item(for: price)
    //        }
    //    }
}

