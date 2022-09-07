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
    private var lineItem: LineItem?
    
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
    
    private func wrapper(_ ad: ALAd) -> Ad? {
        guard
            let lineItem = lineItem,
            ad.zoneIdentifier == lineItem.adUnitId
        else { return nil }
        
        return AppLovinAd(lineItem, ad)
    }
}


extension AppLovinAdViewDemandProvider: DirectDemandProvider {
    func bid(
        _ lineItem: LineItem,
        response: @escaping DemandProviderResponse
    ) {
        self.lineItem = lineItem
        bridge.load(
            sdk.adService,
            lineItem: lineItem,
            completion: response
        )
    }
    
    func fill(
        ad: Ad,
        response: @escaping DemandProviderResponse
    ) {
        guard let ad = ad as? AppLovinAd, ad.wrapped.zoneIdentifier == lineItem?.adUnitId else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        self.response = response
        adView.render(ad.wrapped)
    }
    
    // MARK: Noop
    #warning("Cancel")
    func cancel(_ reason: DemandProviderCancellationReason) {}
    func notify(_ event: AuctionEvent) {}
}


extension AppLovinAdViewDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        return adView
    }
}


extension AppLovinAdViewDemandProvider: ALAdViewEventDelegate {
    func ad(_ ad: ALAd, didFailToDisplayIn adView: ALAdView, withError code: ALAdViewDisplayErrorCode) {
        guard ad.zoneIdentifier == lineItem?.adUnitId else { return }
        
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
        guard let wrapper = wrapper(ad) else { return }
        
        response?(.success(wrapper))
        response = nil
        
        revenueDelegate?.provider(self, didPayRevenueFor: wrapper)
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
