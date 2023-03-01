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
    func show(ad: Ad, from viewController: UIViewController) {
        guard let wrapper = ad as? AdObjectWrapper else {
            delegate?.providerDidFailToDisplay(self, error: SdkError.invalidPresentationState)
            return
        }
        
        wrapper.adObject.present(fromRootViewController: viewController) { [weak self, weak wrapper] in
            guard let wrapper = wrapper, let self = self else { return }
            let rewardWrapper = GoogleMobileAdsRewardWrapper(wrapper.adObject.adReward)
            
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
