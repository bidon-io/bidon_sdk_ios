//
//  RewardedAd.swift
//  Bidon
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import UIKit


@objc(BDNRewardedAd)
public final class RewardedAd: NSObject, RewardedAdObject {
    typealias RewardedMediationObserver = DefaultMediationObserver<AnyRewardedAdDemandProvider>
    typealias RewardedAuctionControllerBuilder = RewardedConcurrentAuctionControllerBuilder<RewardedMediationObserver>

    private typealias Manager = BaseFullscreenAdManager<
        AnyRewardedAdDemandProvider,
        RewardedMediationObserver,
        RewardedAuctionRequestBuilder,
        RewardedAuctionControllerBuilder,
        RewardedImpressionController,
        RewardedImpressionRequestBuilder
    >
    
    @objc public var delegate: RewardedAdDelegate?
    
    @objc public let placement: String
    
    @objc public var isReady: Bool { return manager.isReady }

    @Injected(\.sdk)
    private var sdk: Sdk
    
    private lazy var manager = Manager(
        adType: .rewarded,
        placement: placement,
        delegate: self
    )
    
    @objc public init(
        placement: String = BidonSdk.defaultPlacement
    ) {
        self.placement = placement
        super.init()
    }
    
    @objc public func loadAd(
        with pricefloor: Price = BidonSdk.defaultMinPrice
    ) {
        manager.loadAd(pricefloor: pricefloor)
    }
    
    @objc public func showAd(from rootViewController: UIViewController) {
        manager.show(from: rootViewController)
    }
}


extension RewardedAd: FullscreenAdManagerDelegate {
    func adManager(_ adManager: FullscreenAdManager, didFailToLoad error: SdkError) {
        delegate?.adObject(self, didFailToLoadAd: error)
    }
    
    func adManager(_ adManager: FullscreenAdManager, didLoad ad: Ad) {
        delegate?.adObject(self, didLoadAd: ad)
    }
    
    func adManager(_ adManager: FullscreenAdManager, didFailToPresent impression: Impression?, error: SdkError) {
        delegate?.fullscreenAd(self, didFailToPresentAd: error)
    }
    
    func adManager(_ adManager: FullscreenAdManager, willPresent impression: Impression) {
        delegate?.fullscreenAd(self, willPresentAd: impression.ad)
        delegate?.adObject?(self, didRecordImpression: impression.ad)
    }
    
    func adManager(_ adManager: FullscreenAdManager, didHide impression: Impression) {
        delegate?.fullscreenAd(self, didDismissAd: impression.ad)
    }
    
    func adManager(_ adManager: FullscreenAdManager, didClick impression: Impression) {
        delegate?.adObject?(self, didRecordClick: impression.ad)
    }
    
    func adManager(_ adManager: FullscreenAdManager, didReward reward: Reward, impression: Impression) {
        delegate?.rewardedAd(self, didRewardUser: reward, ad: impression.ad)
    }
    
    func adManager(_ adManager: FullscreenAdManager, didPayRevenue revenue: AdRevenue, ad: Ad) {
        delegate?.adObject?(
            self,
            didPay: revenue,
            ad: ad
        )
    }
}
