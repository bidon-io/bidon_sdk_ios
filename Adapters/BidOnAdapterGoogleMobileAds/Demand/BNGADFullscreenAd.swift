//
//  BNGADFullscreenAd.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import GoogleMobileAds


protocol BNGADFullscreenAdRewardDelegate: AnyObject {
    func rewardedAd(_ rewardedAd: GADRewardedAd, didReceiveReward reward: GADAdReward)
}

protocol BNGADFullscreenAd: GADFullScreenPresentingAd, ResponseInfoProvider {
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (BNGADFullscreenAd?, Error?) -> ()
    )
    
    var rewardDelegate: BNGADFullscreenAdRewardDelegate? { get set }
    
    var paidEventHandler: GADPaidEventHandler? { get set }
    
    func present(fromRootViewController rootViewController: UIViewController)
}


extension GADInterstitialAd: BNGADFullscreenAd {
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (BNGADFullscreenAd?, Error?) -> ()
    ) {
        load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: completion
        )
    }
    
    var rewardDelegate: BNGADFullscreenAdRewardDelegate? {
        get { nil }
        set { }
    }
    
    var info: GADResponseInfo? { Optional(responseInfo) }
}


extension GADRewardedAd: BNGADFullscreenAd {
    private static var rewardDelegateKey: UInt8 = 0
    
    static func request(
        adUnitID: String,
        request: GADRequest,
        completion: @escaping (BNGADFullscreenAd?, Error?) -> ()
    ) {
        load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: completion
        )
    }
    
    var rewardDelegate: BNGADFullscreenAdRewardDelegate? {
        get { objc_getAssociatedObject(self, &GADRewardedAd.rewardDelegateKey) as? BNGADFullscreenAdRewardDelegate }
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
