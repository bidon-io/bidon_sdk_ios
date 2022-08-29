//
//  AppLovinRewardedDemandProvider.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation
import BidOn
import AppLovinSDK
import UIKit



internal final class AppLovinRewardedDemandProvider: NSObject {
    private let sdk: ALSdk
    
    private var interstitial: ALIncentivizedInterstitialAd?
    private var lineItem: LineItem?
    private var response: DemandProviderResponse?
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    init(sdk: ALSdk) {
        self.sdk = sdk
        super.init()
    }
    
    private func wrapper(_ ad: ALAd) -> Ad? {
        guard
            let lineItem = lineItem,
            ad.zoneIdentifier == lineItem.adUnitId
        else { return nil }
        
        return ALAdWrapper(ad, price: lineItem.pricefloor)
    }
}


extension AppLovinRewardedDemandProvider: DirectDemandProvider {
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        let interstitial = ALIncentivizedInterstitialAd(
            zoneIdentifier: lineItem.adUnitId,
            sdk: sdk
        )
        
        interstitial.adVideoPlaybackDelegate = self
        interstitial.preloadAndNotify(self)
        
        self.lineItem = lineItem
        self.interstitial = interstitial
        self.response = response
    }
    
    func load(ad: Ad, response: @escaping DemandProviderResponse) {
        guard
            ad.wrapped is ALAd,
            let interstitial = interstitial,
            interstitial.isReadyForDisplay
        else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        response(.success(ad))
    }
    
    func cancel() {
        interstitial = nil
        response = nil
    }
    
    func notify(_ event: AuctionEvent) {}
}


extension AppLovinRewardedDemandProvider: RewardedAdDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        guard
            let interstitial = interstitial,
            let ad = ad.wrapped as? ALAd,
            ad.zoneIdentifier == lineItem?.adUnitId
        else {
            delegate?.provider(self, didFailToDisplay: ad, error: SdkError.invalidPresentationState)
            return
        }
        
        interstitial.show(ad, andNotify: nil)
    }
}


extension AppLovinRewardedDemandProvider: ALAdLoadDelegate {
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        guard let wrapper = wrapper(ad) else { return }
        
        response?(.success(wrapper))
        response = nil
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        response?(.failure(SdkError.noFill))
        response = nil
    }
}


extension AppLovinRewardedDemandProvider: ALAdVideoPlaybackDelegate {
    func videoPlaybackEnded(
        in ad: ALAd,
        atPlaybackPercent percentPlayed: NSNumber,
        fullyWatched wasFullyWatched: Bool
    ) {
        guard let wrapper = wrapper(ad) else { return }
        
        rewardDelegate?.provider(self, didReceiveReward: ALEmptyReward(), ad: wrapper)
    }
    
    func videoPlaybackBegan(in ad: ALAd) {}
}


extension AppLovinRewardedDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        guard let wrapper = wrapper(ad) else { return }
        
        delegate?.provider(self, didPresent: wrapper)
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        guard let wrapper = wrapper(ad) else { return }
        
        delegate?.provider(self, didHide: wrapper)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        guard let wrapper = wrapper(ad) else { return }
        
        delegate?.provider(self, didClick: wrapper)
    }
}
