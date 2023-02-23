//
//  AppLovinAdViewDemandProvider.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation
import BidOn
import AppLovinSDK
import UIKit


internal final class AppLovinAdViewDemandProvider: NSObject {
    private let sdk: ALSdk
    private let context: AdViewContext
    
    private lazy var adView: ALAdView = {
        let frame = CGRect(origin: .zero, size: context.size)
        
        let adView = ALAdView(
            frame: frame,
            size: context.appLovinAdSize,
            sdk: sdk
        )
        
        adView.adEventDelegate = self
        adView.adDisplayDelegate = self
        
        return adView
    }()
    
    @Injected(\.bridge)
    var bridge: AppLovinAdServiceBridge
    
    private var response: DemandProviderResponse?
    
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    init(
        sdk: ALSdk,
        context: AdViewContext
    ) {
        self.sdk = sdk
        self.context = context
        super.init()
    }
}


extension AppLovinAdViewDemandProvider: DirectDemandProvider {
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
    
    func fill(
        ad: Ad,
        response: @escaping DemandProviderResponse
    ) {
        do {
            try adView.show(ad: ad)
        } catch {
            response(.failure(MediationError.noFill))
        }
    }
    
    func notify(ad: Ad, event: AuctionEvent) {}
}


extension AppLovinAdViewDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        return adView
    }
}


extension AppLovinAdViewDemandProvider: ALAdViewEventDelegate {
    func ad(_ ad: ALAd, didFailToDisplayIn adView: ALAdView, withError code: ALAdViewDisplayErrorCode) {
        response?(.failure(.noFill))
        response = nil
    }
    
    func ad(_ ad: ALAd, didPresentFullscreenFor adView: ALAdView) {
        adViewDelegate?.providerWillPresentModalView(self, adView: adView)
    }
    
    func ad(_ ad: ALAd, didDismissFullscreenFor adView: ALAdView) {
        adViewDelegate?.providerDidDismissModalView(self, adView: adView)
    }
    
    func ad(_ ad: ALAd, willLeaveApplicationFor adView: ALAdView) {
        adViewDelegate?.providerWillLeaveApplication(self, adView: adView)
    }
}


extension AppLovinAdViewDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        guard
            let wrapper = adView.ad,
            wrapper.wrapped.zoneIdentifier == ad.zoneIdentifier
        else { return }
        
        response?(.success(wrapper))
        response = nil
        
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


private extension AdViewContext {
    var appLovinAdSize: ALAdSize {
        switch format {
        case .adaptive:     return UIDevice.bd.isPhone ? .banner : .leader
        case .banner:       return .banner
        case .leaderboard:  return .leader
        case .mrec:         return .mrec
        }
    }
}


extension ALAdView: AdViewContainer {
    public var isAdaptive: Bool {
        return false
    }
}
