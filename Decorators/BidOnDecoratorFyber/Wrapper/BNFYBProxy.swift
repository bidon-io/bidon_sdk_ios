//
//  Proxy.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import FairBidSDK
import BidOn


@objc public final class BNFYBProxy: NSObject {
    internal lazy var bidon = SDK()
    internal lazy var interstitialDelegateMediator = FyberInterstitialDemandProvider.Mediator()
    internal lazy var rewardedDelegateMediator = FyberRewardedAdDemandProvider.Mediator()
    internal lazy var bannerDelegateMediator = FyberBannerDemandProvider.Mediator()

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
    
    @objc public func start(
        withAppId appId: String,
        options: FYBStartOptions = FYBStartOptions()
    ) {
        bidon.initialize { [unowned self] in
            FYBInterstitial.delegate = self.interstitialDelegateMediator
            FYBRewarded.delegate = self.rewardedDelegateMediator
            FYBBanner.delegate = self.bannerDelegateMediator
            
            FairBid.start(
                withAppId: appId,
                options: options
            )
        }
    }
    
    internal func trackAdRevenue(
        _ ad: Ad,
        round: String,
        adType: BidOn.AdType
    ) {
        bidon.trackAdRevenue(
            ad,
            mediation: .fyber,
            auctionRound: round,
            adType: adType
        )
    }
}


@objc public extension FairBid {
    @objc static let bid = BNFYBProxy()
}
