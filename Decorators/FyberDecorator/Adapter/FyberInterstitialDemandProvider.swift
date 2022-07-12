//
//  FyberInterstitialDemandProvider.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import MobileAdvertising
import FairBidSDK


internal final class FyberInterstitialDemandProvider: NSObject {
    weak var delegate: DemandProviderDelegate?
    
    private var response: DemandProviderResponse?
    
    fileprivate let placement: String
    
    init(placement: String) {
        self.placement = placement
        super.init()
        
        FairBid.bid.interstitialDelegateMediator.append(self)
    }
    
    internal final class Mediator: NSObject {
        private let delegates = NSHashTable<FyberInterstitialDemandProvider>(options: .weakMemory)
        
        fileprivate func append(_ delegate: FyberInterstitialDemandProvider) {
            delegates.add(delegate)
        }
        
        fileprivate func delegate(_ placement: String) -> FyberInterstitialDemandProvider? {
            delegates.allObjects.first { $0.placement == placement }
        }
    }
}


extension FyberInterstitialDemandProvider: InterstitialDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        if FYBInterstitial.isAvailable(placement) {
            response(FYBInterstitial.wrappedImpressionData(placement), nil)
        } else {
            self.response = response
            FYBInterstitial.request(placement)
        }
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        FYBInterstitial.show(placement)
    }
    
    func notify(_ event: AuctionEvent) {
        switch event {
        case .lose(_):
            FYBInterstitial.notifyLoss(placement, reason: .lostOnPrice)
        default: break
        }
    }
}


extension FyberInterstitialDemandProvider.Mediator: FYBInterstitialDelegate {
    func interstitialWillRequest(_ placementId: String) {
        delegate(placementId)?.interstitialWillRequest(placementId)
    }
    
    func interstitialIsAvailable(_ placementId: String) {
        delegate(placementId)?.interstitialIsAvailable(placementId)
    }
    
    func interstitialIsUnavailable(_ placementId: String) {
        delegate(placementId)?.interstitialIsUnavailable(placementId)
    }
    
    func interstitialDidShow(_ placementId: String, impressionData: FYBImpressionData) {
        delegate(placementId)?.interstitialDidShow(placementId, impressionData: impressionData)
    }
    
    func interstitialDidFail(toShow placementId: String, withError error: Error, impressionData: FYBImpressionData) {
        delegate(placementId)?.interstitialDidFail(toShow: placementId, withError: error, impressionData: impressionData)
    }
    
    func interstitialDidClick(_ placementId: String) {
        delegate(placementId)?.interstitialDidClick(placementId)
        
    }
    
    func interstitialDidDismiss(_ placementId: String) {
        delegate(placementId)?.interstitialDidDismiss(placementId)
    }
}


extension FyberInterstitialDemandProvider: FYBInterstitialDelegate {
    func interstitialWillRequest(_ placementId: String) {}
    
    func interstitialIsAvailable(_ placementId: String) {
        response?(FYBInterstitial.wrappedImpressionData(placementId), nil)
        response = nil
    }
    
    func interstitialIsUnavailable(_ placementId: String) {
        response?(nil, SDKError("Interstitial is unavailable for placement: \(placementId)"))
        response = nil
    }
    
    func interstitialDidShow(
        _ placementId: String,
        impressionData: FYBImpressionData
    ) {
        delegate?.provider(
            self,
            didPresent: FYBInterstitial.wrappedImpressionData(placementId)
        )
    }
    
    func interstitialDidFail(
        toShow placementId: String,
        withError error: Error,
        impressionData: FYBImpressionData
    ) {
        delegate?.provider(
            self,
            didFailToDisplay: FYBInterstitial.wrappedImpressionData(placementId),
            error: error
        )
    }
    
    func interstitialDidClick(_ placementId: String) {
        delegate?.provider(
            self,
            didClick: FYBInterstitial.wrappedImpressionData(placementId)
        )
    }
    
    func interstitialDidDismiss(_ placementId: String) {
        delegate?.provider(
            self,
            didHide: FYBInterstitial.wrappedImpressionData(placementId)
        )
    }
}
