//
//  RewardedAdDelegate.swift
//  Bidon
//
//  Created by Bidon Team on 12.08.2022.
//

import Foundation

@objc(BDNRewardedAd)
public protocol RewardedAdObject: FullscreenAdObject {}


@objc(BDNRewardedAdDelegate)
public protocol RewardedAdDelegate: FullscreenAdDelegate {
    func rewardedAd(
        _ rewardedAd: RewardedAdObject,
        didRewardUser reward: Reward,
        ad: Ad
    )
}
