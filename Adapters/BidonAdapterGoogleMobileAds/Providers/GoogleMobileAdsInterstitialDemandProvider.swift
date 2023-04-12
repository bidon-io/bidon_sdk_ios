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
    func show(ad: GADInterstitialAd, from viewController: UIViewController) {
        ad.present(fromRootViewController: viewController)
    }
}


extension GoogleMobileAdsInterstitialDemandProvider: GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.providerWillPresent(self)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        guard let ad = ad as? GADInterstitialAd else { return }
        delegate?.provider(
            self,
            didFailToDisplayAd: ad,
            error: .generic(error: error)
        )
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        delegate?.providerDidClick(self)
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.providerDidHide(self)
    }
}

