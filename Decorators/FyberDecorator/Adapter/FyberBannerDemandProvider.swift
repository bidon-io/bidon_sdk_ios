//
//  FyberBannerDemandProvider.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import MobileAdvertising
import FairBidSDK


internal final class FyberBannerDemandProvider: NSObject {
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    weak var delegate: DemandProviderDelegate?
    
    private var banner: FYBBannerAdView?
    private var response: DemandProviderResponse?
    
    fileprivate let placement: String
    
    internal final class Mediator: NSObject {
        private let delegates = NSHashTable<FyberBannerDemandProvider>(options: .weakMemory)
        
        fileprivate func append(_ delegate: FyberBannerDemandProvider) {
            delegates.add(delegate)
        }
        
        fileprivate func delegate(_ placement: String) -> FyberBannerDemandProvider? {
            delegates.allObjects.first { $0.placement == placement }
        }
    }
    
    init(placement: String) {
        self.placement = placement
        super.init()
        
        FairBid.bid.bannerDelegateMediator.append(self)
    }
}


extension FyberBannerDemandProvider: AdViewDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        let options = FYBBannerOptions()
        
        options.placementId = placement
        options.presentingViewController = UIApplication.shared.topViewContoller
        
        FYBBanner.request(with: options)
    }
    
    func notify(_ event: AuctionEvent) {}
    
    func adView(for ad: Ad) -> AdView? {
        return self.banner
    }
}


extension FyberBannerDemandProvider.Mediator: FYBBannerDelegate {
    func bannerDidLoad(_ banner: FYBBannerAdView) {
        delegate(banner.options.placementId)?.bannerDidLoad(banner)
    }
    
    func bannerDidFail(
        toLoad placementId: String,
        withError error: Error
    ) {
        delegate(placementId)?.bannerDidFail(
            toLoad: placementId,
            withError: error
        )
    }
    
    func bannerDidShow(
        _ banner: FYBBannerAdView,
        impressionData: FYBImpressionData
    ) {
        delegate(banner.options.placementId)?.bannerDidShow(
            banner,
            impressionData: impressionData
        )
    }
    
    func bannerDidClick(_ banner: FYBBannerAdView) {
        delegate(banner.options.placementId)?.bannerDidClick(banner)
    }
    
    func bannerWillPresentModalView(_ banner: FYBBannerAdView) {
        delegate(banner.options.placementId)?.bannerWillPresentModalView(banner)
    }
    
    func bannerDidDismissModalView(_ banner: FYBBannerAdView) {
        delegate(banner.options.placementId)?.bannerDidDismissModalView(banner)
    }
    
    func bannerWillLeaveApplication(_ banner: FYBBannerAdView) {
        delegate(banner.options.placementId)?.bannerWillLeaveApplication(banner)
    }
    
    func banner(
        _ banner: FYBBannerAdView,
        didResizeToFrame frame: CGRect
    ) {
        delegate(banner.options.placementId)?.banner(banner, didResizeToFrame: frame)
    }
    
    func bannerWillRequest(_ placementId: String) {
        delegate(placementId)?.bannerWillRequest(placementId)
    }
}


extension FyberBannerDemandProvider: FYBBannerDelegate {
    func bannerDidLoad(_ banner: FYBBannerAdView) {
        self.banner = banner
        response?(banner.wrappedImpressionData, nil)
        response = nil
    }
    
    func bannerDidFail(
        toLoad placementId: String,
        withError error: Error
    ) {
        response?(nil, SDKError(error))
        response = nil
    }
    
    func bannerDidShow(
        _ banner: FYBBannerAdView,
        impressionData: FYBImpressionData
    ) {
        delegate?.provider(self, didPresent: banner.wrappedImpressionData)
    }
    
    func bannerDidClick(_ banner: FYBBannerAdView) {
        delegate?.provider(self, didClick: banner.wrappedImpressionData)
    }
    
    func bannerWillPresentModalView(_ banner: FYBBannerAdView) {
        adViewDelegate?.provider(self, willPresentModalView: banner.wrappedImpressionData)
    }
    
    func bannerDidDismissModalView(_ banner: FYBBannerAdView) {
        adViewDelegate?.provider(self, didDismissModalView: banner.wrappedImpressionData)
    }
    
    func bannerWillLeaveApplication(_ banner: FYBBannerAdView) {
        adViewDelegate?.provider(self, willLeaveApplication: banner.wrappedImpressionData)
    }

    func bannerWillRequest(_ placementId: String) {}
    func banner(
        _ banner: FYBBannerAdView,
        didResizeToFrame frame: CGRect
    ) {}
}


extension FYBBannerAdView: AdView {
    public var isAdaptive: Bool { true }
}
