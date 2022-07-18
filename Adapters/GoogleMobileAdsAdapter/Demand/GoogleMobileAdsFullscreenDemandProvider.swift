//
//  GoogleMobileAdsInterstitialDemandProvider.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import MobileAdvertising
import GoogleMobileAds
import UIKit


internal final class GoogleMobileAdsFullscreenDemandProvider<FullscreenAd: BNGADFullscreenAd>: NSObject, GADFullScreenContentDelegate, BNGADFullscreenAdRewardDelegate {
    
    private let item: (Price) -> LineItem?
    
    private var _item: LineItem?
    
    private var response: DemandProviderResponse?

    private var fullscreenAd: FullscreenAd? {
        didSet {
            fullscreenAd?.fullScreenContentDelegate = self
            fullscreenAd?.rewardDelegate = self
        }
    }
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?

    init(item: @escaping (Price) -> LineItem?) {
        self.item = item
        super.init()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didPresent: wrapped)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didFailToDisplay: wrapped, error: SDKError(error))
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didClick: wrapped)
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didHide: wrapped)
    }
    
    func rewardedAd(
        _ rewardedAd: GADRewardedAd,
        didReceiveReward reward: GADAdReward
    ) {
        guard let wrapped = wrapped(ad: rewardedAd) else { return }
        rewardDelegate?.provider(
            self,
            didReceiveReward: reward.wrapped,
            ad: wrapped
        )
    }
}


extension GoogleMobileAdsFullscreenDemandProvider: InterstitialDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        guard let item = item(pricefloor) else {
            response(nil, SDKError.message("Line item was not found for pricefloor \(pricefloor)"))
            return
        }
        
        self.response = response
        
        let request = GADRequest()
        FullscreenAd.request(
            adUnitID: item.adUnitId,
            request: request
        ) { [weak self] fullscreenAd, error in
            guard let self = self else { return }
            guard let fullscreenAd = fullscreenAd as? FullscreenAd, error == nil else {
                self.response?(nil, SDKError(error))
                self.response = nil
                return
            }
            
            self._item = item
            self.fullscreenAd = fullscreenAd
            
            let wrapped = BNGADResponseInfoWrapper(fullscreenAd, item: item)
            self.response?(wrapped, nil)
            self.response = nil
        }
    }
    
    func cancel() {
        response?(nil, SDKError.cancelled)
        response = nil
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        guard let interstitial = fullscreenAd else {
            delegate?.provider(
                self,
                didFailToDisplay: ad,
                error: SDKError.invalidPresentationState
            )
            return
        }
        interstitial.present(fromRootViewController: viewController)
    }
    
    func notify(_ event: AuctionEvent) {}
    
    private func wrapped(ad: GADFullScreenPresentingAd) -> Ad? {
        guard
            let fullscreenAd = fullscreenAd,
            fullscreenAd === ad,
            let item = _item
        else { return nil }
        
        return BNGADResponseInfoWrapper(
            fullscreenAd,
            item: item
        )
    }
}


extension GoogleMobileAdsFullscreenDemandProvider: RewardedAdDemandProvider {}

