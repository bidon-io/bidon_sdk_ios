//
//  BNMARewardedAdDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import MobileAdvertising


@objc public protocol BNMARewardedAdDelegate: BNMAAdDelegate {
    func didRewardUser(for ad: Ad, with reward: Reward)
}
