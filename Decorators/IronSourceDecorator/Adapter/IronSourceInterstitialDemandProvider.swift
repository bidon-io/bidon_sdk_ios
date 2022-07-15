//
//  IronSourceInterstitialDemandProvider.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


final class IronSourceInterstitialDemandProvider: NSObject, InterstitialDemandProvider {
    struct DisplayArguments {
        var placement: String?
    }
    
    weak var delegate: DemandProviderDelegate?
    
    var load: (() -> ())?
    var displayArguments: (() -> DisplayArguments)?
    
    private var ads = ISAdInfoSet()
    
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        guard let ad = ads.info(with: pricefloor) else {
            response(nil, SDKError("An ad with a price higher than the pricefloor \(pricefloor) was not found"))
            return
        }
        
        response(ad.wrapped, nil)
    }
    
    func cancel() {}

    func notify(_ event: AuctionEvent) {}
    
    func show(ad: Ad, from viewController: UIViewController) {
        if let placement = displayArguments?().placement {
            IronSource.showInterstitial(with: viewController, placement: placement)
        } else {
            IronSource.showInterstitial(with: viewController)
        }
    }
}


extension IronSourceInterstitialDemandProvider: LevelPlayInterstitialDelegate {
    func didLoad(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        ads.insert(adInfo)
        load?()
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        ads.removeAll()
    }
    
    func didShow(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        ads.remove(adInfo)
        delegate?.provider(self, didPresent: adInfo.wrapped)
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didFailToDisplay: adInfo.wrapped, error: error.map { SDKError($0) } ?? SDKError.unknown)

    }
    
    func didClick(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didClick: adInfo.wrapped)
    }
    
    func didClose(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didHide: adInfo.wrapped)
    }
    
    func didOpen(with adInfo: ISAdInfo!) {}
}
