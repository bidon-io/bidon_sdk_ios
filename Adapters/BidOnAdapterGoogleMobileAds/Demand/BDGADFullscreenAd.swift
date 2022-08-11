//
//  BDGADFullscreenAd.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import GoogleMobileAds


protocol BDGADFullscreenAdRewardDelegate: AnyObject {
    func rewardedAd(_ rewardedAd: GADRewardedAd, didReceiveReward reward: GADAdReward)
}


protocol BDGADFullscreenAd: GADFullScreenPresentingAd, ResponseInfoProvider {
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (BDGADFullscreenAd?, Error?) -> ()
    )
    
    var rewardDelegate: BDGADFullscreenAdRewardDelegate? { get set }
    
    var paidEventHandler: GADPaidEventHandler? { get set }
    
    func present(fromRootViewController rootViewController: UIViewController)
}


extension GADInterstitialAd: BDGADFullscreenAd {
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (BDGADFullscreenAd?, Error?) -> ()
    ) {
        load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: completion
        )
    }
    
    var rewardDelegate: BDGADFullscreenAdRewardDelegate? {
        get { nil }
        set { }
    }
    
    var info: GADResponseInfo? { Optional(responseInfo) }
}


extension GADRewardedAd: BDGADFullscreenAd {
    private static var rewardDelegateKey: UInt8 = 0
    
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (BDGADFullscreenAd?, Error?) -> ()
    ) {
        load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: completion
        )
    }
    
    var rewardDelegate: BDGADFullscreenAdRewardDelegate? {
        get { objc_getAssociatedObject(self, &GADRewardedAd.rewardDelegateKey) as? BDGADFullscreenAdRewardDelegate }
        set { objc_setAssociatedObject(self, &GADRewardedAd.rewardDelegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    var info: GADResponseInfo? { Optional(responseInfo) }

    func present(fromRootViewController rootViewController: UIViewController) {
        present(fromRootViewController: rootViewController) { [weak self] in
            guard let self = self else { return }
            self.rewardDelegate?.rewardedAd(self, didReceiveReward: self.adReward)
        }
    }
}
