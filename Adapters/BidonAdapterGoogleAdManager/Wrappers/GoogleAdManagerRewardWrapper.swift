//
//  GoogleAdManagerRewardWrapper.swift
//  BidonAdapterGoogleAdManager
//
//  Created by Stas Kochkin on 16.11.2023.
//

import Foundation
import GoogleMobileAds
import Bidon


typealias GoogleAdManagerRewardWrapper = RewardWrapper<GADAdReward>

extension GoogleAdManagerRewardWrapper {
    convenience init(_ reward: GADAdReward) {
        self.init(
            label: reward.type,
            amount: reward.amount.intValue,
            wrapped: reward
        )
    }
}
