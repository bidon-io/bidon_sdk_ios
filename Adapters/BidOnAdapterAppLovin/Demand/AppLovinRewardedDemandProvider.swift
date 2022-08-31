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
        
        return AppLovinAd(lineItem, ad)
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
            ad is AppLovinAd,
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
            let ad = ad as? AppLovinAd
        else {
            delegate?.providerDidFailToDisplay(self, error: SdkError.invalidPresentationState)
            return
        }
        
        interstitial.show(ad.wrapped, andNotify: nil)
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
        rewardDelegate?.provider(self, didReceiveReward: EmptyReward())
    }
    
    func videoPlaybackBegan(in ad: ALAd) {}
}


extension AppLovinRewardedDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        delegate?.providerWillPresent(self)
        
        guard let wrapper = wrapper(ad) else { return }
        revenueDelegate?.provider(self, didPayRevenueFor: wrapper)
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        delegate?.providerDidHide(self)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.providerDidClick(self)
    }
}
