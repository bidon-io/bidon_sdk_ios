//
//  BNISBannerView.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 15.07.2022.
//

import Foundation
import UIKit
import MobileAdvertising
import IronSource


final class BNISBannerView: AdContainerView {
    let adView: AdView
    
    var load: (() -> ())?
    
    private var shouldLoadOnFetch: Bool = false
    
    internal init(adView: AdView) {
        self.adView = adView
        
        super.init(frame: adView.frame)
        
        self.autorefreshInterval = IronSource.bannerRefreshInterval
        self.isAutorefreshing = !(adView is ISBannerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func destroy() {
        defer { load = nil }
        guard let banner = adView as? ISBannerView else { return }
        IronSource.destroyBanner(banner)
    }
    
    override func preferredSize() -> CGSize {
        return adView.bounds.size
    }
    
    override func loadAd() {
        shouldLoadOnFetch = true
    }
    
    override func fetch(_ completion: @escaping (AdView?) -> ()) {
        defer { completion(adView) }
        defer { shouldLoadOnFetch = false }
        guard shouldLoadOnFetch else { return }
        load?()
    }
}


internal extension ISBannerSize {
    var format: AdViewFormat {
        switch sizeDescription {
        case kSizeRectangle:    return .mrec
        case kSizeLeaderboard:  return .leaderboard
        default: return .banner
        }
    }
}
