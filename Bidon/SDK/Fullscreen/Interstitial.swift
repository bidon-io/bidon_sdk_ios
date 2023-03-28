//
//  Interstitial.swift
//  Bidon
//
//  Created by Bidon Team on 04.08.2022.
//

import Foundation
import UIKit


@objc(BDNInterstitial)
public final class Interstitial: NSObject, FullscreenAdObject {
    private typealias InterstitialMediationObserver = DefaultMediationObserver<AnyInterstitialDemandProvider>
    private typealias InterstitialAuctionControllerBuilder = InterstitialConcurrentAuctionControllerBuilder<InterstitialMediationObserver>
    
    private typealias Manager = BaseFullscreenAdManager<
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


extension Interstitial: FullscreenAdManagerDelegate {
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
    
    func adManager(_ adManager: FullscreenAdManager, didPayRevenue revenue: AdRevenue, ad: Ad) {
        delegate?.adObject?(
            self,
            didPay: revenue,
            ad: ad
        )
    }
    
    func adManager(_ adManager: FullscreenAdManager, didReward reward: Reward, impression: Impression) {}
}

