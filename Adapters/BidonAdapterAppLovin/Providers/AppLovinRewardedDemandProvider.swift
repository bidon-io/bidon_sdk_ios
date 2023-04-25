//
//  AppLovinRewardedDemandProvider.swift
//  BidonAdapterAppLovin
//
//  Created by Bidon Team on 29.08.2022.
//

import Foundation
import Bidon
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
    func load(
        _ adUnitId: String,
        response: @escaping DemandProviderResponse
    ) {
        let interstitial = ALIncentivizedInterstitialAd(
            zoneIdentifier: adUnitId,
            sdk: sdk
        )
        
        interstitial.adDisplayDelegate = self
        interstitial.preloadAndNotify(self)
        
        self.interstitial = interstitial
        self.response = response
    }
    
    // MARK: Noop
    func notify(ad: ALAd, event: AuctionEvent) {}
}


extension AppLovinRewardedDemandProvider: RewardedAdDemandProvider {
    func show(ad: ALAd, from viewController: UIViewController) {
        guard let interstitial = interstitial else {
            delegate?.provider(
                self,
                didFailToDisplayAd: ad,
                error: .invalidPresentationState
            )
            return
        }
        
        interstitial.show(ad, andNotify: self)
    }
}


extension AppLovinRewardedDemandProvider: ALAdLoadDelegate {
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        response?(.success(ad))
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
    
        revenueDelegate?.provider(self, didLogImpression: ad)
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        delegate?.providerDidHide(self)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.providerDidClick(self)
    }
}
