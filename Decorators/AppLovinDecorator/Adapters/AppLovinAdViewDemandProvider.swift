//
//  AppLovinAdViewDemandProvider.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import MobileAdvertising
import AppLovinSDK


internal final class AppLovinAdViewDemandProvider: NSObject, MAAdViewAdDelegate {
    var adView: UIView? { ad }
    
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    private let adUnitIdentifier: String
    private let sdk: ALSdk
    private let adFormat: MAAdFormat
    
    private var response: DemandProviderResponse?
    
    lazy var ad: MAAdView = {
        let size: CGSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: adFormat.adaptiveSize.height
        )
        
        let adView = MAAdView(
            adUnitIdentifier: adUnitIdentifier,
            adFormat: adFormat,
            sdk: sdk
        )
        
        adView.delegate = self
        adView.backgroundColor = .clear
        adView.setExtraParameterForKey(
            "allow_pause_auto_refresh_immediately",
            value: "true"
        )
        adView.frame = CGRect(
            origin: .zero,
            size: size
        )
        
        return adView
    }()
    
    init(
        adUnitIdentifier: String,
        sdk: ALSdk,
        adFormat: MAAdFormat
    ) {
        self.adUnitIdentifier = adUnitIdentifier
        self.sdk = sdk
        self.adFormat = adFormat
        super.init()
    }
    
    func didLoad(_ ad: MAAd) {
        response?(ad.wrapped, nil)
        response = nil
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        response?(nil, error)
        response = nil
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.provider(self, didPresent: ad.wrapped)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.provider(self, didHide: ad.wrapped)
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.provider(self, didClick: ad.wrapped)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        delegate?.provider(self, didFailToDisplay: ad.wrapped, error: error)
    }
    
    func didExpand(_ ad: MAAd) {
        adViewDelegate?.provider(self, didExpandAd: ad.wrapped)
    }
    
    func didCollapse(_ ad: MAAd) {
        adViewDelegate?.provider(self, didCollapseAd: ad.wrapped)
    }
}


extension AppLovinAdViewDemandProvider: AdViewDemandProvider {    
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        ad.stopAutoRefresh()
        ad.loadAd()
    }
    
    func notify(_ event: AuctionEvent) {}
}


extension MAAdFormat {
    var fmt: AdViewFormat {
        let format: AdViewFormat
        
        if self === MAAdFormat.mrec {
            format = .mrec
        } else if self === MAAdFormat.leader {
            format = .leaderboard
        } else {
            format = .banner
        }
        
        return format
    }
}
