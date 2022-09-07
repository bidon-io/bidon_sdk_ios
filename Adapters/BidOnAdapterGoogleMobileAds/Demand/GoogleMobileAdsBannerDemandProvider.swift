//
//  GoogleMobileAdsBannerDemandProvider.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import BidOn
import GoogleMobileAds
import UIKit


internal final class GoogleMobileAdsBannerDemandProvider: NSObject {
    private let context: AdViewContext
    
    private var response: DemandProviderResponse?
    private var lineItem: LineItem?
    
    private lazy var banner: GADBannerView = {
        weak var weakSelf = self
        let banner = GADBannerView(adSize: context.adSize)
        
        banner.delegate = self
        banner.rootViewController = context.rootViewController
        banner.paidEventHandler = weakSelf?.didReceievePaidEvent
        
        return banner
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    init(context: AdViewContext) {
        self.context = context
        super.init()
    }
    
    private func didReceievePaidEvent(_ value: GADAdValue) {
        guard
            let wrapped = wrapped(ad: banner)
        else { return }
        
        revenueDelegate?.provider(self, didPayRevenueFor: wrapped)
    }
}


extension GoogleMobileAdsBannerDemandProvider: DirectDemandProvider {
    func bid(
        _ lineItem: LineItem,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        
        let request = GADRequest()
        banner.adUnitID = lineItem.adUnitId
        banner.load(request)
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard ad.id == wrapped(ad: banner)?.id else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        response(.success(ad))
    }
    
    func notify(_ event: AuctionEvent) {}
    
    func cancel(_ reason: DemandProviderCancellationReason) {
        defer { response = nil }
        switch reason {
        case .timeoutReached: response?(.failure(.bidTimeoutReached))
        case .lifecycle: response?(.failure(.auctionCancelled))
        }
    }
}


extension GoogleMobileAdsBannerDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        return banner
    }
    
    private func wrapped(ad: GADBannerView) -> Ad? {
        guard
            banner === ad,
            let responseInfo = banner.responseInfo,
            let lineItem = lineItem
        else { return nil }
        
        return GoogleMobileAdsAd(lineItem, responseInfo)
    }
}


extension GoogleMobileAdsBannerDemandProvider: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard let wrapped = wrapped(ad: bannerView) else { return }
        response?(.success(wrapped))
        response = nil
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        response?(.failure(MediationError(gadError: error)))
        response = nil
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        adViewDelegate?.providerWillPresentModalView(self, adView: bannerView)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        adViewDelegate?.providerDidDismissModalView(self, adView: bannerView)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        delegate?.providerDidClick(self)
    }
}


extension AdViewContext {
    var adSize: GADAdSize {
        switch (format, isAdaptive) {
        case (.mrec, _): return GADAdSizeMediumRectangle
        case (.banner, false): return GADAdSizeBanner
        case (.leaderboard, false): return GADAdSizeLeaderboard
        default: return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        }
    }
    
    private var width: CGFloat {
        guard let window = UIApplication.shared.bd.window else { return 0 }
        if #available(iOS 11, *) {
            return window.bounds.inset(by: window.safeAreaInsets).width
        } else {
            return window.bounds.width
        }
    }
}


extension GADBannerView: AdViewContainer {
    public var isAdaptive: Bool { return true }
}
