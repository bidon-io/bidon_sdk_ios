//
//  RewardedAd.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit


@objc(BDRewardedAd)
public final class RewardedAd: NSObject, RewardedAdObject {
    private typealias Manager = FullscreenAdManager<RewardedAuctionRequestBuilder, RewardedConcurrentAuctionControllerBuilder, RewardedImpressionController>
    
    @objc public var delegate: RewardedAdDelegate?
    
    @objc public let placement: String
    
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


extension RewardedAd: FullscreenAdManagerDelegate {
    func didFailToLoad(_ error: Error) {
        delegate?.adObject(self, didFailToLoadAd: error)
    }
    
    func didFailToPresent(_ ad: Ad?, error: Error) {
        delegate?.fullscreenAd(self, didFailToPresentAd: error)
    }
    
    func didLoad(_ ad: Ad) {
        delegate?.adObject(self, didLoadAd: ad)
    }
    
    func didPresent(_ ad: Ad) {
        delegate?.fullscreenAd(self, willPresentAd: ad)
    }
    
    func didHide(_ ad: Ad) {
        delegate?.fullscreenAd(self, didDismissAd: ad)
    }
    
    func didClick(_ ad: Ad) {
        delegate?.adObject?(self, didRecordClick: ad)
    }
    
    func didReceiveReward(_ reward: Reward, ad: Ad) {
        delegate?.rewardedAd(self, didRewardUser: reward)
    }
}


extension RewardedAd: AuctionControllerDelegate {
    func controllerDidStartAuction(_ controller: AuctionController) {}
    
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
