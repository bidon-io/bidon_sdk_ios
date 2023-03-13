//
//  AppLovinInterstitialDemandProvider.swift
//  BidonAdapterAppLovin
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import Bidon
import AppLovinSDK
import UIKit


internal final class AppLovinInterstitialDemandProvider: NSObject {
    typealias AdType = AppLovinAdWrapper
    
    private let sdk: ALSdk
    
    @Injected(\.bridge)
    var bridge: AppLovinAdServiceBridge
    
    private lazy var interstitial: ALInterstitialAd = {
        let interstitial = ALInterstitialAd(sdk: sdk)
        interstitial.adDisplayDelegate = self
        return interstitial
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    init(sdk: ALSdk) {
        self.sdk = sdk
        super.init()
    }
}


extension AppLovinInterstitialDemandProvider: DirectDemandProvider {
    func bid(
        _ lineItem: LineItem,
        response: @escaping DemandProviderResponse
    ) {
        bridge.load(
            service: sdk.adService,
            lineItem: lineItem,
            response: response
        )
    }
    
    func fill(ad: AppLovinAdWrapper, response: @escaping DemandProviderResponse) {
        response(.success(ad))
    }
    
    func notify(ad: AppLovinAdWrapper, event: AuctionEvent) {}
}


extension AppLovinInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: AppLovinAdWrapper, from viewController: UIViewController) {
        interstitial.show(ad: ad)
    }
}


extension AppLovinInterstitialDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        delegate?.providerWillPresent(self)
        
        guard
            let wrapper = interstitial.ad,
            wrapper.id == interstitial.ad?.id
        else { return }
        
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
