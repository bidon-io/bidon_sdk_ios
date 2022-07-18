//
//  AppLovinDemandSourceAdapter.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation
import MobileAdvertising
import AppLovinSDK


internal final class AppLovinFullscreenDemandProvider<FullscreenAd: MAFullscreenAd>: NSObject, MARewardedAdDelegate {
    lazy var fullscreenAd: FullscreenAd = {
        let ad = FullscreenAd.ad(adUnitIdentifier, sdk: sdk)
        ad.adDelegate = self
        ad.rewardDelegate = self
        return ad
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    private let adUnitIdentifier: String
    private let sdk: ALSdk?
    private let displayArguments: () -> FullscreenAdDisplayArguments?
    private var response: DemandProviderResponse?
    
    init(
        adUnitIdentifier: String,
        displayArguments: @escaping @autoclosure () -> FullscreenAdDisplayArguments?,
        sdk: ALSdk?
    ) {
        self.sdk = sdk
        self.displayArguments = displayArguments
        self.adUnitIdentifier = adUnitIdentifier
    }
    
    func didLoad(_ ad: MAAd) {
        response?(ad.wrapped, nil)
        response = nil
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        response?(nil, error)
        response = nil
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.provider(self, didPresent: ad.wrapped)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.provider(self, didHide: ad.wrapped)
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.provider(self, didClick: ad.wrapped)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        delegate?.provider(self, didFailToDisplay: ad.wrapped, error: error)
    }
    
    func didStartRewardedVideo(for ad: MAAd) {}
    
    func didCompleteRewardedVideo(for ad: MAAd) {}
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        rewardDelegate?.provider(
            self,
            didReceiveReward: reward.wrapped,
            ad: ad.wrapped
        )
    }
}


extension AppLovinFullscreenDemandProvider: InterstitialDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        fullscreenAd.load()
    }
    
    func cancel() {
        response?(nil, SDKError.cancelled)
        response = nil
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        let args = displayArguments()
        fullscreenAd.show(args, from: viewController)
    }
    
    func notify(_ event: AuctionEvent) {}
}

extension AppLovinFullscreenDemandProvider: RewardedAdDemandProvider {}


