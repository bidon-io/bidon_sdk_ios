//
//  Proxy.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


@objc public final class Proxy: NSObject {
    internal lazy var bidon = SDK()
    internal lazy var interstitial = BNISInterstitialRouter()
    internal lazy var rewardedVideo = BNISRewardedVideoRouter()
    internal lazy var banner = BNISBannerRouter()

    public func register<T: ParameterizedAdapter>(
        adapter: T.Type,
        parameters: T.Parameters
    ) {
        bidon.register(
            adapter: adapter,
            parameters: parameters
        )
    }
    
    @objc public func register(adapter: Adapter) throws {
        try bidon.register(adapter: adapter)
    }
    
    @objc public func initWithAppKey(
        _ appKey: String,
        adUnits: [String] = [IS_BANNER, IS_INTERSTITIAL, IS_OFFERWALL, IS_REWARDED_VIDEO],
        delegate: ISInitializationDelegate? = nil
    ) {
        bidon.initialize { [unowned self] in
            // Set level play delegates
            IronSource.setLevelPlayInterstitialDelegate(self.interstitial.mediator)
            IronSource.setLevelPlayRewardedVideoDelegate(self.rewardedVideo.mediator)
            IronSource.setLevelPlayBannerDelegate(self.banner.mediator)

            IronSource.initWithAppKey(
                appKey,
                adUnits: adUnits,
                delegate: delegate
            )
        }
    }
    
    @objc public func setInterstitialDelegate(_ delegate: ISInterstitialDelegate) {
        interstitial.delegate = delegate
    }
    
    @objc public func setLevelPlayInterstitialDelegate(_ delegate: BNLevelPlayInterstitialDelegate) {
        interstitial.levelPlayDelegate = delegate
    }
    
    @objc public func setAuctionInterstitialDelegate(_ delegate: BNISAuctionDelegate) {
        interstitial.auctionDelegate = delegate
    }
    
    @objc public func setRewardedVideoDelegate(_ delegate: ISRewardedVideoDelegate) {
        rewardedVideo.delegate = delegate
    }
    
    @objc public func setLevelPlayRewardedVideoDelegate(_ delegate: BNLevelPlayRewardedVideoDelegate) {
        rewardedVideo.levelPlayDelegate = delegate
    }
    
    @objc public func setAuctionRewardedVideoDelegate(_ delegate: BNISAuctionDelegate) {
        rewardedVideo.auctionDelegate = delegate
    }
    
    @objc public func setBannerDelegate(_ delegate: BNISBannerDelegate) {
        banner.delegate = delegate
    }
    
    @objc public func setLevelPlayBannerDelegate(_ delegate: BNLevelPlayBannerDelegate) {
        banner.levelPlayDelegate = delegate
    }
    
    @objc public func setAuctionBannerDelegate(_ delegate: BNISAuctionDelegate) {
        banner.auctionDelegate = delegate
    }
    
    @objc public func setInterstitialAuctionResolver(_ auctionResolver: AuctionResolver) {
        interstitial.resolver = auctionResolver
    }
    
    @objc public func setRewardedVideoAuctionResolver(_ auctionResolver: AuctionResolver) {
        rewardedVideo.resolver = auctionResolver
    }
    
    @objc public func showInterstitial(
        with viewController: UIViewController,
        placement: String? = nil
    ) {
        interstitial.show(
            from: viewController,
            placement: placement
        )
    }

    
    @objc public func showRewardedVideo(
        with viewController: UIViewController,
        placement: String? = nil
    ) {
        rewardedVideo.show(
            from: viewController,
            placement: placement
        )
    }
    
    @objc public func destroyBanner(_ view: UIView) {
        banner.destroy(view)
    }
}


public extension IronSource {
    @objc static let bid = Proxy()
}

