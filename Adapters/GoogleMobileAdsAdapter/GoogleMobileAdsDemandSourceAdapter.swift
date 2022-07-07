//
//  GoogleMobileAdsDemandSourceAdapter.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import GoogleMobileAds
import MobileAdvertising


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter


@objc public final class GoogleMobileAdsDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public let id: String = "admob"
    
    public let parameters: GoogleMobileAdsParameters
    
    public init(parameters: GoogleMobileAdsParameters) {
        self.parameters = parameters
        super.init()
    }
    
    public func interstitial() throws -> InterstitialDemandProvider {
        GoogleMobileAdsFullscreenDemandProvider<GADInterstitialAd> { [weak self] price in
            return self?.parameters.lineItems.interstitial?.item(for: price)
        }
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        GoogleMobileAdsFullscreenDemandProvider<GADRewardedAd> { [weak self] price in
            return self?.parameters.lineItems.rewardedAd?.item(for: price)
        }
    }
}


extension GoogleMobileAdsDemandSourceAdapter: ParameterizedAdapter {
    public typealias Parameters = GoogleMobileAdsParameters
    
    @objc public convenience init(rawParameters: Data) throws {
        let parameters = try JSONDecoder().decode(
            GoogleMobileAdsParameters.self,
            from: rawParameters
        )
        self.init(parameters: parameters)
    }
}


extension GoogleMobileAdsDemandSourceAdapter: InitializableAdapter {
    @available(iOS 13, *)
    public func initialize() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            initilize { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public func initilize(
        _ completion: @escaping (Error?) -> ()
    ) {
        GADMobileAds.sharedInstance().start { _ in
            completion(nil)
        }
    }
}
