//
//  IronSourceRewardedAdDemandProvider.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import IronSource
import BidOn


final class IronSourceRewardedAdDemandProvider: NSObject, RewardedAdDemandProvider {
    struct DisplayArguments {
        var placement: String?
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
            IronSource.showRewardedVideo(with: viewController, placement: placement)
        } else {
            IronSource.showRewardedVideo(with: viewController)
        }
    }
}


extension IronSourceRewardedAdDemandProvider: LevelPlayRewardedVideoDelegate {
    func didFailToShowWithError(
        _ error: Error!,
        andAdInfo adInfo: ISAdInfo!
    ) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(
            self,
            didFailToDisplay: adInfo.wrapped,
            error: error.map { SDKError($0) } ?? .unknown
        )
    }
    
    func didOpen(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didPayRevenueFor: adInfo.wrapped)
        delegate?.provider(self, didPresent: adInfo.wrapped)
    }
    
    func didClose(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didHide: adInfo.wrapped)
    }
    
    func hasAvailableAd(with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        ads.insert(adInfo)
        load?()
    }
        
    func didReceiveReward(
        forPlacement placementInfo: ISPlacementInfo!,
        with adInfo: ISAdInfo!
    ) {
        guard
            let adInfo = adInfo,
            let reward = placementInfo
        else { return }
        
        rewardDelegate?.provider(
            self,
            didReceiveReward: reward.wrapped,
            ad: adInfo.wrapped
        )
    }
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        guard let adInfo = adInfo else { return }
        delegate?.provider(self, didClick: adInfo.wrapped)
    }
    
    func hasNoAvailableAd() {
        ads.removeAll()
    }
}
