//
//  AppLovinInterstitialDemandProvider.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import BidOn
import AppLovinSDK
import UIKit


internal final class AppLovinInterstitialDemandProvider: NSObject {
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
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard ad is AppLovinAdWrapper else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        response(.success(ad))
    }

    func notify(ad: Ad, event: AuctionEvent) {}
}


extension AppLovinInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        do {
            try interstitial.show(ad: ad)
        } catch {
            delegate?.providerDidFailToDisplay(self, error: SdkError(error))
        }
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
