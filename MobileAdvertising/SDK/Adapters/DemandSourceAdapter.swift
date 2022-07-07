//
//  DemandAdapter.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation


public protocol InterstitialDemandSourceAdapter: Adapter {
    func interstitial() throws -> InterstitialDemandProvider
}

public protocol RewardedAdDemandSourceAdapter: Adapter {
    func rewardedAd() throws -> RewardedAdDemandProvider
}
