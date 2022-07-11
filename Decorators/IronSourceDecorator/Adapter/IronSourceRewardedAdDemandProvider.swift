//
//  IronSourceRewardedAdDemandProvider.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


final class IronSourceRewardedAdDemandProvider: NSObject, RewardedAdDemandProvider {
    struct DisplayArguments {
        var placement: String?
        var instanceId: String?
    }
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?

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
            IronSource.showISDemandOnlyRewardedVideo(viewController, instanceId: instanceId)
        } else if let placement = displayArguments?().placement {
            IronSource.showRewardedVideo(with: viewController, placement: placement)
        } else {
            IronSource.showRewardedVideo(with: viewController)
        }
    }
}


extension IronSourceRewardedAdDemandProvider: LevelPlayRewardedVideoDelegate {
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        
    }
    
    func didOpen(with adInfo: ISAdInfo!) {
        
    }
    
    func didClose(with adInfo: ISAdInfo!) {
        
    }
    
    func hasAvailableAd(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        ads.insert(adInfo)
        load?()
    }
    
    func hasNoAvailableAd() {
        
    }
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        
    }
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        
    }
}
