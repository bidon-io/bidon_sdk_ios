//
//  BidMachineBannerDemandProvider.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import MobileAdvertising
import BidMachine
import UIKit


internal final class BidMachineBannerDemandProvider: NSObject {
    private let context: AdViewContext

    private var response: DemandProviderResponse?
    
    private lazy var request = BDMBannerRequest()
    
    private lazy var banner: BDMBannerView = {
        let banner = BDMBannerView()
        banner.delegate = self
        banner.rootViewController = context.rootViewController
        banner.frame = CGRect(
            origin: .zero,
            size: context.size
        )
        return banner
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    init(context: AdViewContext) {
        self.context = context
        super.init()
    }
}


extension BidMachineBannerDemandProvider: AdViewDemandProvider {
    var adView: AdView? { banner }

    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        request.priceFloors = [pricefloor.bdm]
        request.adSize = BDMBannerAdSize(context.format)
        banner.populate(with: request)
    }
    
    func notify(_ event: AuctionEvent) {
        switch (event) {
        case .win:
            request.notifyMediationWin()
        case .lose(let ad):
            request.notifyMediationLoss(ad.dsp, ecpm: ad.price as NSNumber)
        }
    }
}

 
extension BidMachineBannerDemandProvider: BDMBannerDelegate {
    func bannerViewReady(toPresent bannerView: BDMBannerView) {
        response?(bannerView.adObject.wrapped, nil)
        response = nil
    }
    
    func bannerView(_ bannerView: BDMBannerView, failedWithError error: Error) {
        response?(nil, error)
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


extension BDMBannerView: AdView {
    public var isAdaptive: Bool { return false }
}
