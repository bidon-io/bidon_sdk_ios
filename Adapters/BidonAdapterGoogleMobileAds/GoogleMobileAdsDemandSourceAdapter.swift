//
//  GoogleMobileAdsDemandSourceAdapter.swift
//  GoogleMobileAdsAdapter
//
//  Created by Bidon Team on 06.07.2022.
//

import Foundation
import GoogleMobileAds
import Bidon


internal typealias DemandSourceAdapter = InitializableAdapter & InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc
public final class GoogleMobileAdsDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public static let identifier = "admob"
    
    public let identifier: String = GoogleMobileAdsDemandSourceAdapter.identifier
    public let name: String = "Google Mobile Ads"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = GADMobileAds.sharedInstance().sdkVersion
    
    @Injected(\.context)
    var context: Bidon.AuctionContext
    
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = context.isTestMode ?
        [GADSimulatorID] :
        nil
        
        GADMobileAds.sharedInstance().start { _ in
            completion(.success(()))
        }
    }
    
    public func interstitial() throws -> InterstitialDemandProvider {
        return GoogleMobileAdsInterstitialDemandProvider()
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        return GoogleMobileAdsRewardedAdDemandProvider()
    }
    
    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
        return GoogleMobileAdsBannerDemandProvider(context: context)
    }
}

