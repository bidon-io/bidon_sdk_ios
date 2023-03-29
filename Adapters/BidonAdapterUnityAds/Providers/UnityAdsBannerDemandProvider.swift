//
//  UnityAdsBannerDemandProvider.swift
//  BidonAdapterUnityAds
//
//  Created by Bidon Team on 02.03.2023.
//

import Foundation
import Bidon
import UnityAds
import UIKit


#warning("Ad Revenue for Unity Ads banners")
final class UnityAdsBannerDemandProvider: NSObject, DirectDemandProvider {
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    private let context: AdViewContext
    private var banner: UADSBannerView?
    private var response: DemandProviderResponse?
    
    init(context: AdViewContext) {
        self.context = context
        super.init()
    }
    
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        let banner = UADSBannerView(
            placementId: lineItem.adUnitId,
            size: context.size
        )
        
        banner.delegate = self
        
        self.response = response
        self.banner = banner
        
        banner.load()
    }
    
    func fill(ad: UADSBannerView, response: @escaping DemandProviderResponse) {
        response(.success(ad))
    }
    
    func notify(ad: UADSBannerView, event: Bidon.AuctionEvent) {}
}


extension UnityAdsBannerDemandProvider: AdViewDemandProvider {
    func container(for ad: UADSBannerView) -> AdViewContainer? {
        return ad
    }
}


extension UnityAdsBannerDemandProvider: UADSBannerViewDelegate {
    func bannerViewDidLoad(_ bannerView: UADSBannerView!) {
        guard let banner = banner, self.banner === banner else { return }
        
        response?(.success(banner))
        response = nil
    }
    
    func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!) {
        guard self.banner === bannerView else { return }
        
        response?(.failure(MediationError(error)))
        response = nil
    }
    
    func bannerViewDidClick(_ bannerView: UADSBannerView!) {
        guard self.banner === bannerView else { return }
        
        delegate?.providerDidClick(self)
    }
    
    func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView!) {
        guard let banner = banner, self.banner === bannerView else { return }
        
        adViewDelegate?.providerWillLeaveApplication(self, adView: banner)
    }
}


extension UADSBannerView: AdViewContainer {
    public var isAdaptive: Bool { false }
}
