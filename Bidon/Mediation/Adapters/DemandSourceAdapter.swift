//
//  DemandAdapter.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 29.06.2022.
//

import Foundation


public protocol InterstitialDemandSourceAdapter: Adapter {
    func interstitial() throws -> any InterstitialDemandProvider
}


public protocol RewardedAdDemandSourceAdapter: Adapter {
    func rewardedAd() throws -> any RewardedAdDemandProvider
}


public protocol AdViewDemandSourceAdapter: Adapter {
    func adView(_ context: AdViewContext) throws -> any AdViewDemandProvider
}
