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


private extension ALInterstitialAd {
    private static var adKey: UInt8 = 0
    
    var ad: Ad? {
        get { objc_getAssociatedObject(self, &ALInterstitialAd.adKey) as? Ad }
        set { objc_setAssociatedObject(self, &ALInterstitialAd.adKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    
    func show(_ ad: Ad) throws {
        guard let wrapped = ad.wrapped as? ALAd else {
            throw SdkError.internalInconsistency
        }
        
        self.ad = ad
        show(wrapped)
    }
}


internal final class AppLovinInterstitialDemandProvider: NSObject {
    private let sdk: ALSdk
    
    @Injected(\.bridge)
    var bridge: AdServiceBridge
    
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
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        bridge.load(
            sdk.adService,
            lineItem: lineItem,
            completion: response
        )
    }
    
    func load(ad: Ad, response: @escaping DemandProviderResponse) {
        guard ad.wrapped is ALAd else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        response(.success(ad))
    }
    
    func cancel() {}
    
    func notify(_ event: AuctionEvent) {}
}


extension AppLovinInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        do {
            try interstitial.show(ad)
        } catch {
            delegate?.provider(self, didFailToDisplay: ad, error: error)
        }
    }
}


extension AppLovinInterstitialDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        guard let wrapper = interstitial.ad, wrapper.wrapped === ad else { return }
        delegate?.provider(self, didPresent: wrapper)
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        guard let wrapper = interstitial.ad, wrapper.wrapped === ad else { return }
        delegate?.provider(self, didHide: wrapper)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        guard let wrapper = interstitial.ad, wrapper.wrapped === ad else { return }
        delegate?.provider(self, didClick: wrapper)
    }
}
