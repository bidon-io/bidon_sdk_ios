//
//  GoogleMobileAdsRewardedAdDemandProvider.swift
//  BidonAdapterGoogleMobileAds
//
//  Created by Bidon Team on 23.02.2023.
//

import Foundation
import Bidon
import GoogleMobileAds
import UIKit


final class GoogleMobileAdsRewardedAdDemandProvider: GoogleMobileAdsBaseDemandProvider<GADRewardedAd> {
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    override func loadAd(_ request: GADRequest, lineItem: LineItem) {
        GADRewardedAd.load(withAdUnitID: lineItem.adUnitId, request: request) { [weak self] rewardedAd, _ in
            guard let self = self else { return }
            
            guard let rewardedAd = rewardedAd else {
                self.handleDidFailToLoad(.noBid)
                return
            }
            
            rewardedAd.fullScreenContentDelegate = self
            
            self.setupAdRevenueHandler(rewardedAd, lineItem: lineItem)
            
            self.handleDidLoad(adObject: rewardedAd, lineItem: lineItem)
        }
    }
}


extension GoogleMobileAdsRewardedAdDemandProvider: RewardedAdDemandProvider {
    func show(ad: GADRewardedAd, from viewController: UIViewController) {
        ad.present(fromRootViewController: viewController) { [weak self, weak ad] in
            guard let ad = ad, let self = self else { return }
            
            let rewardWrapper = GoogleMobileAdsRewardWrapper(ad.adReward)
            self.rewardDelegate?.provider(self, didReceiveReward: rewardWrapper)
        }
    }
}


extension GoogleMobileAdsRewardedAdDemandProvider: GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.providerWillPresent(self)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        delegate?.providerDidFailToDisplay(self, error: SdkError(error))
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        delegate?.providerDidClick(self)
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.providerDidHide(self)
    }
}
