//
//  GoogleMobileAdsInterstitialDemandProvider.swift
//  GoogleMobileAdsAdapter
//
//  Created by Bidon Team on 06.07.2022.
//

import Foundation
import Bidon
import GoogleMobileAds
import UIKit


final class GoogleMobileAdsInterstitialDemandProvider: GoogleMobileAdsBaseDemandProvider<GADInterstitialAd> {
    override func loadAd(_ request: GADRequest, lineItem: LineItem) {
        GADInterstitialAd.load(withAdUnitID: lineItem.adUnitId, request: request) { [weak self] interstitial, _ in
            guard let self = self else { return }
            
            guard let interstitial = interstitial else {
                self.handleDidFailToLoad(.noBid)
                return
            }
            
            interstitial.fullScreenContentDelegate = self
            
            self.setupAdRevenueHandler(interstitial, lineItem: lineItem)
            
            self.handleDidLoad(adObject: interstitial, lineItem: lineItem)
        }
    }
}


extension GoogleMobileAdsInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: GoogleMobileAdsAdWrapper<GADInterstitialAd>, from viewController: UIViewController) {
        ad.adObject.present(fromRootViewController: viewController)
    }
}


extension GoogleMobileAdsInterstitialDemandProvider: GADFullScreenContentDelegate {
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

