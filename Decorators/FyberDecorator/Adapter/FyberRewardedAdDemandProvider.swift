//
//  FyberRewardedAdDemandProvider.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import MobileAdvertising
import FairBidSDK


internal final class FyberRewardedAdDemandProvider: NSObject {
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    private var response: DemandProviderResponse?
    
    fileprivate let placement: String
    
    init(placement: String) {
        self.placement = placement
        super.init()
        
        FairBid.bid.rewardedDelegateMediator.append(self)
    }
    
    internal final class Mediator: NSObject {
        private let delegates = NSHashTable<FyberRewardedAdDemandProvider>(options: .weakMemory)
        
        fileprivate func append(_ delegate: FyberRewardedAdDemandProvider) {
            delegates.add(delegate)
        }
        
        fileprivate func delegate(_ placement: String) -> FyberRewardedAdDemandProvider? {
            delegates.allObjects.first { $0.placement == placement }
        }
    }
}


extension FyberRewardedAdDemandProvider: RewardedAdDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        if FYBRewarded.isAvailable(placement) {
            response(FYBRewarded.wrappedImpressionData(placement), nil)
        } else {
            self.response = response
            FYBRewarded.request(placement)
        }
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        FYBRewarded.show(placement)
    }
    
    func notify(_ event: AuctionEvent) {
        switch event {
        case .lose(_):
            FYBRewarded.notifyLoss(placement, reason: .lostOnPrice)
        default: break
        }
    }
}


extension FyberRewardedAdDemandProvider.Mediator: FYBRewardedDelegate {
    func rewardedWillRequest(_ placementId: String) {
        delegate(placementId)?.rewardedWillRequest(placementId)
    }
    
    func rewardedIsAvailable(_ placementId: String) {
        delegate(placementId)?.rewardedIsAvailable(placementId)
    }
    
    func rewardedIsUnavailable(_ placementId: String) {
        delegate(placementId)?.rewardedIsUnavailable(placementId)
    }
    
    func rewardedDidShow(_ placementId: String, impressionData: FYBImpressionData) {
        delegate(placementId)?.rewardedDidShow(placementId, impressionData: impressionData)
    }
    
    func rewardedDidFail(toShow placementId: String, withError error: Error, impressionData: FYBImpressionData) {
        delegate(placementId)?.rewardedDidFail(toShow: placementId, withError: error, impressionData: impressionData)
    }
    
    func rewardedDidClick(_ placementId: String) {
        delegate(placementId)?.rewardedDidClick(placementId)
        
    }
    
    func rewardedDidDismiss(_ placementId: String) {
        delegate(placementId)?.rewardedDidDismiss(placementId)
    }
}


extension FyberRewardedAdDemandProvider: FYBRewardedDelegate {
    func rewardedWillRequest(_ placementId: String) {}
    
    func rewardedIsAvailable(_ placementId: String) {
        response?(FYBRewarded.wrappedImpressionData(placementId), nil)
        response = nil
    }
    
    func rewardedIsUnavailable(_ placementId: String) {
        response?(nil, SDKError("Rewarded is unavailable for placement: \(placementId)"))
        response = nil
    }
    
    func rewardedDidShow(
        _ placementId: String,
        impressionData: FYBImpressionData
    ) {
        delegate?.provider(
            self,
            didPresent: FYBRewarded.wrappedImpressionData(placementId)
        )
    }
    
    func rewardedDidFail(
        toShow placementId: String,
        withError error: Error,
        impressionData: FYBImpressionData
    ) {
        delegate?.provider(
            self,
            didFailToDisplay: FYBRewarded.wrappedImpressionData(placementId),
            error: error
        )
    }
    
    func rewardedDidClick(_ placementId: String) {
        delegate?.provider(
            self,
            didClick: FYBRewarded.wrappedImpressionData(placementId)
        )
    }
    
    func rewardedDidDismiss(_ placementId: String) {
        delegate?.provider(
            self,
            didHide: FYBRewarded.wrappedImpressionData(placementId)
        )
    }
}
