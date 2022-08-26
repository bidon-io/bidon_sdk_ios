//
//  RewardedAdDelegate.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation

@objc(BDRewardedAd)
public protocol RewardedAdObject: FullscreenAdObject {}


@objc(BDRewardedAdDelegate)
public protocol RewardedAdDelegate: FullscreenAdDelegate {
    func rewardedAd(
        _ rewardedAd: RewardedAdObject,
        didRewardUser reward: Reward
    )
}
