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


final class UnityAdsBannerDemandProvider: NSObject, DirectDemandProvider {
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    private let context: AdViewContext
    private var banner: UnityAdsBannerAdWrapper?
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
        self.banner = UnityAdsBannerAdWrapper(
            lineItem: lineItem,
            bannerView: banner
        )
        
        banner.load()
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        if let ad = ad as? UnityAdsBannerAdWrapper, ad.id == banner?.id {
            response(.success(ad))
        } else {
            response(.failure(.noFill))
        }
    }
    
    func notify(ad: Ad, event: Bidon.AuctionEvent) {}
}


extension UnityAdsBannerDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        (ad as? UnityAdsBannerAdWrapper)?.bannerView
    }
}


extension UnityAdsBannerDemandProvider: UADSBannerViewDelegate {
    func bannerViewDidLoad(_ bannerView: UADSBannerView!) {
        guard let banner = banner, banner.bannerView === bannerView else { return }
        
        response?(.success(banner))
        response = nil
    }
    
    func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!) {
        guard let banner = banner, banner.bannerView === bannerView else { return }
        
        response?(.failure(MediationError(error)))
        response = nil
    }
    
    func bannerViewDidClick(_ bannerView: UADSBannerView!) {
        guard let banner = banner, banner.bannerView === bannerView else { return }
        
        delegate?.providerDidClick(self)
    }
    
    func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView!) {
        guard let banner = banner, banner.bannerView === bannerView else { return }
        
        adViewDelegate?.providerWillLeaveApplication(self, adView: banner.bannerView)
    }
}


extension UADSBannerView: AdViewContainer {
    public var isAdaptive: Bool { false }
}
