//
//  BNGADAdRewardWrapper.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import GoogleMobileAds
import MobileAdvertising


final class BNGADAdReward: NSObject, Reward {
    private let _wrapped: GADAdReward
    
    var wrapped: AnyObject { _wrapped }
    
    var amount: Int { _wrapped.amount.intValue }
    var label: String { _wrapped.type }
    
    init(_ wrapped: GADAdReward) {
        self._wrapped = wrapped
        super.init()
    }
}


extension GADAdReward {
    var wrapped: Reward { BNGADAdReward(self) }
}

