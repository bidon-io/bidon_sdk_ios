//
//  BDGADFullscreenAd.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import GoogleMobileAds


protocol GoogleMobileAdsFullscreenAdRewardDelegate: AnyObject {
    func rewardedAd(_ rewardedAd: GADRewardedAd, didReceiveReward reward: GADAdReward)
}


protocol GoogleMobileAdsFullscreenAd: GADFullScreenPresentingAd {
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (GoogleMobileAdsFullscreenAd?, Error?) -> ()
    )
    
    var responseInfo: GADResponseInfo { get }
    
    var rewardDelegate: GoogleMobileAdsFullscreenAdRewardDelegate? { get set }
    
    var paidEventHandler: GADPaidEventHandler? { get set }
    
    func present(fromRootViewController rootViewController: UIViewController)
}


extension GADInterstitialAd: GoogleMobileAdsFullscreenAd {
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (GoogleMobileAdsFullscreenAd?, Error?) -> ()
    ) {
        load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: completion
        )
    }
    
    var rewardDelegate: GoogleMobileAdsFullscreenAdRewardDelegate? {
        get { nil }
        set { }
    }
}


extension GADRewardedAd: GoogleMobileAdsFullscreenAd {
    private static var rewardDelegateKey: UInt8 = 0
    
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (GoogleMobileAdsFullscreenAd?, Error?) -> ()
    ) {
        load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: completion
        )
    }
    
    var rewardDelegate: GoogleMobileAdsFullscreenAdRewardDelegate? {
        get { objc_getAssociatedObject(self, &GADRewardedAd.rewardDelegateKey) as? GoogleMobileAdsFullscreenAdRewardDelegate }
        set { objc_setAssociatedObject(self, &GADRewardedAd.rewardDelegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    func present(fromRootViewController rootViewController: UIViewController) {
        present(fromRootViewController: rootViewController) { [weak self] in
            guard let self = self else { return }
            self.rewardDelegate?.rewardedAd(self, didReceiveReward: self.adReward)
        }
    }
}
