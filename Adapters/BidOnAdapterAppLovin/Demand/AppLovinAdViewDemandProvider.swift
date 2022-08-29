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
    var bridge: AdServiceBridge
    
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
        
        return ALAdWrapper(ad, price: lineItem.pricefloor)
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
    
    func load(
        ad: Ad,
        response: @escaping DemandProviderResponse
    ) {
        guard let ad = ad.wrapped as? ALAd, ad.zoneIdentifier == lineItem?.adUnitId else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        self.response = response
        adView.render(ad)
    }
    
    func cancel() {}
    
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
        
        response?(.failure(SdkError.noFill))
        response = nil
    }
    
    func ad(_ ad: ALAd, didPresentFullscreenFor adView: ALAdView) {
        guard let wrapper = wrapper(ad) else { return }
        
        adViewDelegate?.provider(self, willPresentModalView: wrapper)
    }
    
    func ad(_ ad: ALAd, didDismissFullscreenFor adView: ALAdView) {
        guard let wrapper = wrapper(ad) else { return }

        adViewDelegate?.provider(self, didDismissModalView: wrapper)
    }
    
    func ad(_ ad: ALAd, willLeaveApplicationFor adView: ALAdView) {
        guard let wrapper = wrapper(ad) else { return }
        
        adViewDelegate?.provider(self, willLeaveApplication: wrapper)
    }
}


extension AppLovinAdViewDemandProvider: ALAdDisplayDelegate {
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        guard let wrapper = wrapper(ad) else { return }
        
        response?(.success(wrapper))
        response = nil
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        guard let wrapper = wrapper(ad) else { return }
        
        delegate?.provider(self, didHide: wrapper)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        guard let wrapper = wrapper(ad) else { return }
        
        delegate?.provider(self, didClick: wrapper)
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
