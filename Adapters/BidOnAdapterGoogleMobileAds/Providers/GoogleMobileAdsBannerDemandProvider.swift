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


final class GoogleMobileAdsBannerDemandProvider: GoogleMobileAdsBaseDemandProvider<GADBannerView> {
    private let context: AdViewContext
    
    private var lineItem: LineItem?
    private var banner: GADBannerView?
    
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    init(context: AdViewContext) {
        self.context = context
        super.init()
    }

    override func loadAd(_ request: GADRequest, lineItem: LineItem) {
        self.lineItem = lineItem
        let banner = GADBannerView(adSize: context.adSize)
                
        banner.delegate = self
        banner.adUnitID = lineItem.adUnitId
        banner.rootViewController = context.rootViewController
        
        setupAdRevenueHandler(banner, lineItem: lineItem)
        
        banner.load(request)
        
        self.banner = banner
    }
}


extension GoogleMobileAdsBannerDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        return (ad as? AdObjectWrapper)?.adObject
    }
}


extension GoogleMobileAdsBannerDemandProvider: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard let lineItem = lineItem else { return }
        handleDidLoad(adObject: bannerView, lineItem: lineItem)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        handleDidFailToLoad(.noBid)
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
        switch format {
        case .mrec: return GADAdSizeMediumRectangle
        case .banner: return GADAdSizeBanner
        case .leaderboard: return GADAdSizeLeaderboard
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
