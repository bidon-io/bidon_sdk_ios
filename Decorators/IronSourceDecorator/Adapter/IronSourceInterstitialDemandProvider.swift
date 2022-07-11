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
        var instanceId: String?
    }
    
    weak var delegate: DemandProviderDelegate?
    
    var load: (() -> ())?
    var displayArguments: (() -> DisplayArguments)?
    
    private var ads = Set<ISAdInfo>()
    
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        guard
            let ad = ads.first(where: { $0.revenue.doubleValue >= pricefloor })
        else {
            response(nil, SDKError("An ad with a price higher than the pricefloor \(pricefloor) was not found"))
            return
        }
        
        ads.remove(ad)
        response(ad.wrapped, nil)
    }
    
    func notify(_ event: AuctionEvent) {}
    
    func show(ad: Ad, from viewController: UIViewController) {
        if let instanceId = displayArguments?().instanceId {
            IronSource.showISDemandOnlyInterstitial(viewController, instanceId: instanceId)
        } else if let placement = displayArguments?().placement {
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
        
    }
    
    func didOpen(with adInfo: ISAdInfo!) {
        
    }
    
    func didShow(with adInfo: ISAdInfo!) {
        
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        
    }
    
    func didClick(with adInfo: ISAdInfo!) {
        
    }
    
    func didClose(with adInfo: ISAdInfo!) {
        
    }
}
