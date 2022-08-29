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
    private typealias Request = RequestWrapper<BDMBannerRequest>
    
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
    
    func cancel() {
        request.cancel()
    }
    
    func notify(_ event: AuctionEvent) {
        request.notify(event)
    }
}


extension BidMachineBannerDemandProvider: AdViewDemandProvider {
    func load(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let adObject = ad.wrapped as? BDMAdProtocol else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        self.response = response
        banner.rootViewController = context.rootViewController
        banner.loadAd(adObject)
    }
    
    func container(for ad: Ad) -> AdViewContainer? {
        return banner
    }
}


extension BidMachineBannerDemandProvider: BDMBannerDelegate {
    func bannerViewReady(toPresent bannerView: BDMBannerView) {
        response?(.success(banner.adObject.wrapped))
        response = nil
    }
    
    func bannerView(_ bannerView: BDMBannerView, failedWithError error: Error) {
        response?(.failure(error))
        response = nil
    }
    
    func bannerViewWillPresentScreen(_ bannerView: BDMBannerView) {
        adViewDelegate?.provider(self, willPresentModalView: bannerView.adObject.wrapped)
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BDMBannerView) {
        adViewDelegate?.provider(self, didDismissModalView: bannerView.adObject.wrapped)
    }
    
    func bannerViewWillLeaveApplication(_ bannerView: BDMBannerView) {
        adViewDelegate?.provider(self, willLeaveApplication: bannerView.adObject.wrapped)
    }
    
    func bannerViewRecieveUserInteraction(_ bannerView: BDMBannerView) {
        delegate?.provider(self, didClick: bannerView.adObject.wrapped)
    }
    
    func bannerViewDidExpire(_ bannerView: BDMBannerView) {}
}


extension BidMachineBannerDemandProvider: BDMAdEventProducerDelegate {
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        revenueDelegate?.provider(self, didPayRevenueFor: banner.adObject.wrapped)
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {}
}


extension BDMBannerAdSize {
    init(_ format: AdViewFormat) {
        switch format {
        case .banner:
            self = .size320x50
        case .leaderboard:
            self = .size728x90
        case .mrec:
            self = .size300x250
        }
    }
}


extension BDMBannerView: AdViewContainer {
    public var isAdaptive: Bool { return false }
}
