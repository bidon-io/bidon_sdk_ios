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
        let banner = GADBannerView(adSize: context.adSize)
        banner.delegate = self
        banner.paidEventHandler = { [weak self] _ in
            guard
                let self = self,
                let wrapped = self.wrapped(ad: self.banner)
            else { return }
            
            self.delegate?.provider(self, didPayRevenueFor: wrapped)
        }
        return GADBannerView(adSize: GADAdSizeBanner)
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?

    init(context: AdViewContext) {
        self.context = context
        super.init()
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
        banner.rootViewController = context.rootViewController

        banner.load(request)
    }
    
    func load(ad: Ad) {
        
    }
    
    func notify(_ event: AuctionEvent) {}

    func cancel() {
        response?(.failure(SdkError.cancelled))
        response = nil
    }
}


extension GoogleMobileAdsBannerDemandProvider: AdViewDemandProvider {
    func adView(for ad: Ad) -> AdView? {
        return banner
    }

    private func wrapped(ad: GADBannerView) -> Ad? {
        guard
            banner === ad,
            let lineItem = lineItem
        else { return nil }

        return BDGADResponseInfoWrapper(
            ad,
            lineItem: lineItem
        )
    }
}


extension GoogleMobileAdsBannerDemandProvider: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard let wrapped = wrapped(ad: bannerView) else { return }
        response?(.success(wrapped))
        response = nil
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        guard wrapped(ad: bannerView) != nil else { return }
        response?(.failure(error))
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        guard let wrapped = wrapped(ad: bannerView) else { return }
        adViewDelegate?.provider(self, willPresentModalView: wrapped)
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        guard let wrapped = wrapped(ad: bannerView) else { return }
        adViewDelegate?.provider(self, didDismissModalView: wrapped)
    }

    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        guard let wrapped = wrapped(ad: bannerView) else { return }
        delegate?.provider(self, didClick: wrapped)
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


extension GADBannerView: AdView {
    public var isAdaptive: Bool { return true }
}
