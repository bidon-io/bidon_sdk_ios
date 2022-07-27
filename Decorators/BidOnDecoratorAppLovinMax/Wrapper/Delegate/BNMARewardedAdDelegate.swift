//
//  BNMARewardedAdDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import BidOn


@objc public protocol BNMARewardedAdDelegate: BNMAAdDelegate {
    @objc(didRewardUserForAd:withReward:)
    func didRewardUser(for ad: Ad, with reward: Reward)
}
