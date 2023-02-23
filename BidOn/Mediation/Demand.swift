//
//  Demand.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


protocol Demand {
    associatedtype Provider
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var ad: Ad { get }
    var provider: Provider { get }
}


struct DemandModel<Provider>: Demand {
    var auctionId: String
    var auctionConfigurationId: Int
    var ad: Ad
    var provider: Provider
}


typealias AdViewDemand = DemandModel<AdViewDemandProvider>
typealias InterstitialDemand = DemandModel<InterstitialDemandProvider>
typealias RewardedAdDemand = DemandModel<RewardedAdDemandProvider>


typealias AnyAdViewDemand = DemandModel<AnyAdViewDemandProvider>
typealias AnyInterstitialDemand = DemandModel<AnyInterstitialDemandProvider>
typealias AnyRewardedAdDemand = DemandModel<AnyRewardedAdDemandProvider>


extension AnyAdViewDemand {
    func unwrapped() -> AdViewDemand {
        return AdViewDemand(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            ad: ad,
            provider: provider.wrapped
        )
    }
}


extension AnyInterstitialDemand {
    func unwrapped() -> InterstitialDemand {
        return InterstitialDemand(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            ad: ad,
            provider: provider.wrapped
        )
    }
}


extension AnyRewardedAdDemand {
    func unwrapped() -> RewardedAdDemand {
        return RewardedAdDemand(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            ad: ad,
            provider: provider.wrapped
        )
    }
}
