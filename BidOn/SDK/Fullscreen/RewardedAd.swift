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
    typealias RewardedMediationObserver = DefaultMediationObserver<AnyRewardedAdDemandProvider>
    typealias RewardedAuctionControllerBuilder = RewardedConcurrentAuctionControllerBuilder<RewardedMediationObserver>

    private typealias Manager = FullscreenAdManager<
        AnyRewardedAdDemandProvider,
        RewardedMediationObserver,
        RewardedAuctionRequestBuilder,
        RewardedAuctionControllerBuilder,
        RewardedImpressionController,
        RewardedImpressionRequestBuilder
    >
    
    @objc public var delegate: RewardedAdDelegate?
    
    @objc public let placement: String
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private lazy var manager = Manager(
        adType: .rewarded,
        placement: placement,
        delegate: self
    )
    
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
    func didStartAuction() {
        delegate?.adObjectDidStartAuction?(self)
    }
    
    func didStartAuctionRound(_ round: AuctionRound, pricefloor: Price) {
        delegate?.adObject?(self, didStartAuctionRound: round.id, pricefloor: pricefloor)
    }
    
    func didReceiveBid(_ ad: Ad) {
        delegate?.adObject?(self, didReceiveBid: ad)
    }
    
    func didCompleteAuctionRound(_ round: AuctionRound) {
        delegate?.adObject?(self, didCompleteAuctionRound: round.id)
    }
    
    func didCompleteAuction(_ winner: Ad?) {
        delegate?.adObject?(self, didCompleteAuction: winner)
    }
    
    func didFailToLoad(_ error: SdkError) {
        delegate?.adObject(self, didFailToLoadAd: error)
    }
    
    func didLoad(_ ad: Ad) {
        delegate?.adObject(self, didLoadAd: ad)
    }
    
    func didFailToPresent(_ impression: Impression?, error: SdkError) {
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
    }
    
    func didReceiveReward(_ reward: Reward, impression: Impression) {
        delegate?.rewardedAd(self, didRewardUser: reward)
    }
}
