//
//  RewardedAdDelegate.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation

@objc(BDRewardedAd)
public protocol RewardedAd: FullscreenAd {}


@objc(BDRewardedAdDelegate)
public protocol RewardedAdDelegate: FullscreenAdDelegate {
    func rewardedAd(
        _ rewardedAd: RewardedAd,
        didRewardUser reward: Reward
    )
}
