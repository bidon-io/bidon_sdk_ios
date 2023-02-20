//
//  Interstitial.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation
import UIKit


@objc(BDNInterstitial)
public final class Interstitial: NSObject, FullscreenAdObject {
    private typealias InterstitialMediationObserver = DefaultMediationObserver<AnyInterstitialDemandProvider>
    private typealias InterstitialAuctionControllerBuilder = InterstitialConcurrentAuctionControllerBuilder<InterstitialMediationObserver>

    private typealias Manager = FullscreenAdManager<
        AnyInterstitialDemandProvider,
        InterstitialMediationObserver,
        InterstitialAuctionRequestBuilder,
        InterstitialAuctionControllerBuilder,
        InterstitialImpressionController,
        InterstitialImpressionRequestBuilder
    >
    
    @objc public var delegate: FullscreenAdDelegate?
    
    @objc public let placement: String
    
    @objc public var isReady: Bool { return manager.isReady }
        
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private lazy var manager = Manager(
        adType: .interstitial,
        placement: placement,
        delegate: self
    )
    
    @objc public init(
        placement: String = BidOnSdk.defaultPlacement
    ) {
        self.placement = placement
        super.init()
    }
    
    @objc public func loadAd(
        with pricefloor: Price = BidOnSdk.defaultMinPrice
    ) {
        manager.loadAd(pricefloor: pricefloor)
    }
    
    @objc public func showAd(from rootViewController: UIViewController) {
        manager.show(from: rootViewController)
    }
}


extension Interstitial: FullscreenAdManagerDelegate {
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
    
    func didReceiveReward(_ reward: Reward, impression: Impression) {}
}

