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
    
    var ad: AppLovinAd? {
        get { objc_getAssociatedObject(self, &ALInterstitialAd.adKey) as? AppLovinAd }
        set { objc_setAssociatedObject(self, &ALInterstitialAd.adKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func show(_ ad: Ad) throws {
        guard let ad = ad as? AppLovinAd else {
            throw SdkError.internalInconsistency
        }
        
        self.ad = ad
        show(ad.wrapped)
    }
}


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
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        bridge.load(
            sdk.adService,
            lineItem: lineItem,
            completion: response
        )
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard ad is AppLovinAd else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        response(.success(ad))
    }
    
    // MARK: Noop
    #warning("Cancel")
    func cancel(_ reason: DemandProviderCancellationReason) {}
    func notify(_ event: AuctionEvent) {}
}


extension AppLovinInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        do {
            try interstitial.show(ad)
        } catch {
            delegate?.providerDidFailToDisplay(self, error: SdkError(error))
        }
    }
}


extension AppLovinInterstitialDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        delegate?.providerWillPresent(self)
        
        guard let wrapper = interstitial.ad else { return }
        revenueDelegate?.provider(self, didPayRevenueFor: wrapper)
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        delegate?.providerDidHide(self)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        delegate?.providerDidClick(self)
    }
}
