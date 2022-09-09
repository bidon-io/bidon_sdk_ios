//
//  BidMachineBannerDemandProvider.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import BidOn
import BidMachine
import UIKit


internal final class BidMachineBannerDemandProvider: NSObject {
    private typealias Request = BidMachineRequestWrapper<BDMBannerRequest>
    
    private let context: AdViewContext
    
    private var response: DemandProviderResponse?
    
    private lazy var request: Request = {
        let request = BDMBannerRequest()
        request.adSize = BDMBannerAdSize(context.format)
        return Request(request: request)
    }()
    
    private lazy var banner: BDMBannerView = {
        let banner = BDMBannerView()
        banner.delegate = self
        banner.producerDelegate = self
        banner.rootViewController = context.rootViewController
        banner.frame = CGRect(
            origin: .zero,
            size: context.size
        )
        return banner
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    init(context: AdViewContext) {
        self.context = context
        super.init()
    }
}


extension BidMachineBannerDemandProvider: ProgrammaticDemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        request.bid(pricefloor, response: response)
    }
    
    func cancel(_ reason: DemandProviderCancellationReason) {
        request.cancel(reason)
    }
    
    func notify(_ event: AuctionEvent) {
        request.notify(event)
    }
}


extension BidMachineBannerDemandProvider: AdViewDemandProvider {
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let ad = ad as? BidMachineAd else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        self.response = response
        banner.rootViewController = context.rootViewController
        banner.loadAd(ad.wrapped)
    }
    
    func container(for ad: Ad) -> AdViewContainer? {
        return banner
    }
}


extension BidMachineBannerDemandProvider: BDMBannerDelegate {
    func bannerViewReady(toPresent bannerView: BDMBannerView) {
        guard let adObject = bannerView.adObject else { return }
        
        response?(.success(BidMachineAd(adObject)))
        response = nil
    }
    
    func bannerView(_ bannerView: BDMBannerView, failedWithError error: Error) {
        response?(.failure(.noFill))
        response = nil
    }
    
    func bannerViewWillPresentScreen(_ bannerView: BDMBannerView) {
        adViewDelegate?.providerWillPresentModalView(self, adView: bannerView)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BDMBannerView) {
        adViewDelegate?.providerDidDismissModalView(self, adView: bannerView)
    }
    
    func bannerViewWillLeaveApplication(_ bannerView: BDMBannerView) {
        adViewDelegate?.providerWillLeaveApplication(self, adView: bannerView)
    }
    
    func bannerViewRecieveUserInteraction(_ bannerView: BDMBannerView) {
        delegate?.providerDidClick(self)
    }
    
    func bannerViewDidExpire(_ bannerView: BDMBannerView) {}
}


extension BidMachineBannerDemandProvider: BDMAdEventProducerDelegate {
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        guard let adObject = banner.adObject else { return }
        
        revenueDelegate?.provider(self, didPayRevenueFor: BidMachineAd(adObject))
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {}
}


extension BDMBannerAdSize {
    init(_ format: AdViewFormat) {
        switch format {
        case .adaptive: self = .sizeUnknown
        case .banner: self = .size320x50
        case .leaderboard: self = .size728x90
        case .mrec: self = .size300x250
        }
    }
}


extension BDMBannerView: AdViewContainer {
    public var isAdaptive: Bool { return false }
}
