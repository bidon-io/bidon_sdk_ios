//
//  GoogleMobileAdsInterstitialDemandProvider.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import BidOn
import GoogleMobileAds
import UIKit


internal final class GoogleMobileAdsFullscreenDemandProvider<FullscreenAd: GoogleMobileAdsFullscreenAd>: NSObject, GADFullScreenContentDelegate, GoogleMobileAdsFullscreenAdRewardDelegate {
    private var response: DemandProviderResponse?
    private var lineItem: LineItem?
    
    private var fullscreenAd: FullscreenAd? {
        didSet {
            fullscreenAd?.fullScreenContentDelegate = self
            fullscreenAd?.rewardDelegate = self
            fullscreenAd?.paidEventHandler = { [weak self] _ in
                guard
                    let self = self,
                    let fullscreenAd = self.fullscreenAd,
                    let wrapped = self.wrapped(ad: fullscreenAd)
                else { return }
                
                self.revenueDelegate?.provider(self, didPayRevenueFor: wrapped)
            }
        }
    }
    
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
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
    
    func rewardedAd(
        _ rewardedAd: GADRewardedAd,
        didReceiveReward reward: GADAdReward
    ) {
        rewardDelegate?.provider(self, didReceiveReward: GoogleMobileAdsReward(reward))
    }
}


extension GoogleMobileAdsFullscreenDemandProvider: DirectDemandProvider {
    func bid(
        _ lineItem: LineItem,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        
        let request = GADRequest()
        FullscreenAd.request(
            adUnitID: lineItem.adUnitId,
            request: request
        ) { [weak self] fullscreenAd, error in
            guard let self = self else { return }
            
            guard let fullscreenAd = fullscreenAd as? FullscreenAd else {
                self.response?(.failure(.unknownAdapter))
                self.response = nil
                return
            }
            
            self.lineItem = lineItem
            self.fullscreenAd = fullscreenAd
            
            let wrapped = GoogleMobileAdsAd(lineItem, fullscreenAd.responseInfo)
            
            self.response?(.success(wrapped))
            self.response = nil
        }
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard
            let fullscreenAd = fullscreenAd,
            ad.id == wrapped(ad: fullscreenAd)?.id
        else {
            response(.failure(.noFill))
            return
        }
        
        response(.success(ad))
    }
    
    func notify(_ event: AuctionEvent) {}
    
    func cancel(_ reason: DemandProviderCancellationReason) {
        defer { response = nil }
        switch reason {
        case .timeoutReached: response?(.failure(.bidTimeoutReached))
        case .lifecycle: response?(.failure(.auctionCancelled))
        }
    }
    
    private func wrapped(ad: GADFullScreenPresentingAd) -> Ad? {
        guard
            let fullscreenAd = fullscreenAd,
            fullscreenAd === ad,
            let lineItem = lineItem
        else { return nil }
        
        return GoogleMobileAdsAd(lineItem, fullscreenAd.responseInfo)
    }
}


extension GoogleMobileAdsFullscreenDemandProvider: InterstitialDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        guard let interstitial = fullscreenAd else {
            delegate?.providerDidFailToDisplay(self, error: SdkError.invalidPresentationState)
            return
        }
        
        interstitial.present(fromRootViewController: viewController)
    }
}


extension GoogleMobileAdsFullscreenDemandProvider: RewardedAdDemandProvider {}

