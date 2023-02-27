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
    private var response: DemandProviderResponse?
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    init(sdk: ALSdk) {
        self.sdk = sdk
        super.init()
    }
}


extension AppLovinRewardedDemandProvider: DirectDemandProvider {
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        let interstitial = ALIncentivizedInterstitialAd(
            lineItem: lineItem,
            sdk: sdk
        )
        
        interstitial.adDisplayDelegate = self
        interstitial.preloadAndNotify(self)
        
        self.interstitial = interstitial
        self.response = response
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard
            ad is AppLovinAdWrapper,
            let interstitial = interstitial,
            interstitial.isReadyForDisplay
        else {
            response(.failure(.noFill))
            return
        }
        
        response(.success(ad))
    }
    
    // MARK: Noop
    func notify(ad: Ad, event: AuctionEvent) {}
}


extension AppLovinRewardedDemandProvider: RewardedAdDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        guard
            let interstitial = interstitial,
            let ad = ad as? AppLovinAdWrapper
        else {
            delegate?.providerDidFailToDisplay(self, error: SdkError.invalidPresentationState)
            return
        }
        
        interstitial.show(ad.wrapped, andNotify: self)
    }
}


extension AppLovinRewardedDemandProvider: ALAdLoadDelegate {
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        guard
            let lineItem = interstitial?.lineItem,
            lineItem.adUnitId == ad.zoneIdentifier
        else {
            response?(.failure(.incorrectAdUnitId))
            response = nil
            return
        }
        
        let wrapper = AppLovinAdWrapper(lineItem: lineItem, ad: ad)
        response?(.success(wrapper))
        response = nil
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        response?(.failure(.noFill))
        response = nil
    }
}


extension AppLovinRewardedDemandProvider: ALAdRewardDelegate {
    func rewardValidationRequest(
        for ad: ALAd,
        didSucceedWithResponse response: [AnyHashable : Any]
    ) {
        let reward = AppLovinRewardWrapper(response)
        rewardDelegate?.provider(self, didReceiveReward: reward)
    }
    
    // MARK: No-op
    func rewardValidationRequest(
        for ad: ALAd,
        didExceedQuotaWithResponse response: [AnyHashable : Any]
    ) {}
    
    func rewardValidationRequest(
        for ad: ALAd,
        wasRejectedWithResponse response: [AnyHashable : Any]
    ) {}
    
    func rewardValidationRequest(
        for ad: ALAd,
        didFailWithError responseCode: Int
    ) {}
}


extension AppLovinRewardedDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        defer { delegate?.providerWillPresent(self) }
        
        guard
            let lineItem = interstitial?.lineItem,
            lineItem.adUnitId == ad.zoneIdentifier
        else { return }

        let wrapper = AppLovinAdWrapper(lineItem: lineItem, ad: ad)
        let revenue = AppLovinAdRevenueWrapper(wrapper)
        revenueDelegate?.provider(self, didPay: revenue, ad: wrapper)
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        delegate?.providerDidHide(self)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.providerDidClick(self)
    }
}
