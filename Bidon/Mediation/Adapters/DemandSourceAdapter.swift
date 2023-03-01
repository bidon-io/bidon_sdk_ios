//
//  DemandAdapter.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 29.06.2022.
//

import Foundation


public protocol InterstitialDemandSourceAdapter: Adapter {
    func interstitial() throws -> InterstitialDemandProvider
}


public protocol RewardedAdDemandSourceAdapter: Adapter {
    func rewardedAd() throws -> RewardedAdDemandProvider
}


public protocol AdViewDemandSourceAdapter: Adapter {
    func adView(_ context: AdViewContext) throws -> AdViewDemandProvider
}
