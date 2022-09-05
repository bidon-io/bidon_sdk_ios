//
//  Interstitial.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation
import UIKit


@objc(BDInterstitial)
public final class Interstitial: NSObject, FullscreenAdObject {
    private typealias Manager = FullscreenAdManager<
        AnyInterstitialDemandProvider,
        InterstitialAuctionRequestBuilder,
        InterstitialConcurrentAuctionControllerBuilder<DefaultMediationObserver>,
        InterstitialImpressionController
    >
    
    @objc public var delegate: FullscreenAdDelegate?
    
    @objc public let placement: String
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private lazy var manager: Manager = {
        let manager = Manager(placement: placement)
        manager.delegate = self
        return manager
    }()
    
    @objc public init(placement: String = "") {
        self.placement = placement
        super.init()
    }
    
    @objc public func loadAd() {
        manager.loadAd()
    }
    
    @objc public func show(from rootViewController: UIViewController) {
        manager.show(from: rootViewController)
    }
}


extension Interstitial: FullscreenAdManagerDelegate {
    func didFailToLoad(_ error: Error) {
        delegate?.adObject(self, didFailToLoadAd: error)
    }
    
    func didLoad(_ ad: Ad) {
        delegate?.adObject(self, didLoadAd: ad)
    }
    
    func didFailToPresent(_ impression: Impression?, error: Error) {
        delegate?.fullscreenAd(self, didFailToPresentAd: error)
    }
    
    func willPresent(_ impression: Impression) {
        delegate?.fullscreenAd(self, willPresentAd: impression.ad)
        delegate?.adObject?(self, didRecordImpression: impression.ad)
    }
    
    func didHide(_ impression: Impression) {
        delegate?.fullscreenAd(self, didDismissAd: impression.ad)
    }
    
    func didClick(_ impression: Impression) {
        delegate?.adObject?(self, didRecordClick: impression.ad)
    }
    
    func didPayRevenue(_ ad: Ad) {
        delegate?.adObject?(self, didPayRevenue: ad)
        
        sdk.trackAdRevenue(ad, adType: .interstitial)
    }
    
    func didReceiveReward(_ reward: Reward, impression: Impression) {}
}


extension Interstitial: AuctionControllerDelegate {
    func controllerDidStartAuction(_ controller: AuctionController) {
        delegate?.adObjectDidStartAuction?(self)
    }
    
    func controller(_ controller: AuctionController, didStartRound round: AuctionRound, pricefloor: Price) {
        delegate?.adObject?(self, didStartAuctionRound: round.id, pricefloor: pricefloor)
    }
    
    func controller(_ controller: AuctionController, didReceiveAd ad: Ad, provider: DemandProvider) {
        delegate?.adObject?(self, didReceiveBid: ad)
    }
    
    func controller(_ controller: AuctionController, didCompleteRound round: AuctionRound) {
        delegate?.adObject?(self, didCompleteAuctionRound: round.id)
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        delegate?.adObject?(self, didCompleteAuction: winner)
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        delegate?.adObject?(self, didCompleteAuction: nil)
    }
}
