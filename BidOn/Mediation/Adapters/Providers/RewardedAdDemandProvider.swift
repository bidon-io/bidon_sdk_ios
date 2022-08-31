//
//  RewardedAdDemandProvider.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation

public protocol DemandProviderRewardDelegate: AnyObject {
    func provider(
        _ provider: DemandProvider,
        didReceiveReward reward: Reward
    )
}

public protocol RewardedAdDemandProvider: InterstitialDemandProvider {
    var rewardDelegate: DemandProviderRewardDelegate? { get set }
}
