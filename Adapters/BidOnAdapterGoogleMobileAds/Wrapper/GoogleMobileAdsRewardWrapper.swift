//
//  BDGADAdRewardWrapper.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import GoogleMobileAds
import BidOn


typealias GoogleMobileAdsRewardWrapper = RewardWrapper<GADAdReward>

extension GoogleMobileAdsRewardWrapper {
    convenience init(_ reward: GADAdReward) {
        self.init(
            label: reward.type,
            amount: reward.amount.intValue,
            wrapped: reward
        )
    }
}
