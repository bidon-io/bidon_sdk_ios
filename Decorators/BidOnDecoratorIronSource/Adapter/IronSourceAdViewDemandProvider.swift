//
//  IronSourceAdViewDemandProvider.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import IronSource
import BidOn


final class IronSourceAdViewDemandProvider: NSObject {
    weak var delegate: DemandProviderDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    private var response: DemandProviderResponse?
    
    var load: (() -> ())?

    private var ads = ISAdInfoSet()
    private var banners = NSMapTable<ISAdInfo, ISBannerView>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
}


extension IronSourceAdViewDemandProvider: AdViewDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        guard let ad = ads.info(with: pricefloor) else {
            response(nil, SdkError("An ad with a price higher than the pricefloor \(pricefloor) was not found"))
            return
        }
    
        response(ad.wrapped, nil)
    }
    
    func cancel() {}
    
    func notify(_ event: AuctionEvent) {}
    
    func adView(for ad: Ad) -> AdView? {
        guard let ad = ad.wrapped as? ISAdInfo else { return nil }
        return banners.object(forKey: ad)
    }
}

// TODO: Revenue for banners
extension IronSourceAdViewDemandProvider: LevelPlayBannerDelegate {
    func didLoad(_ bannerView: ISBannerView!, with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        ads.insert(adInfo)
        banners.setObject(bannerView, forKey: adInfo)
        load?()
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        ads.removeAll()
    }
    
    func didClick(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didClick: adInfo.wrapped)
    }
    
    func didLeaveApplication(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        adViewDelegate?.provider(self, willLeaveApplication: adInfo.wrapped)
    }
    
    func didPresentScreen(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        adViewDelegate?.provider(self, willPresentModalView: adInfo.wrapped)
    }
    
    func didDismissScreen(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        adViewDelegate?.provider(self, didDismissModalView: adInfo.wrapped)
    }
}


extension ISBannerView: AdView {
    public var isAdaptive: Bool { return true }
}
