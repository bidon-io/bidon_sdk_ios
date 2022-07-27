//
//  BNMARewardWrapper.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import AppLovinSDK
import BidOn


final class BNMARewardWrapper: NSObject, Reward {
    private let _wrapped: MAReward
    
    var wrapped: AnyObject { _wrapped }
    
    var label: String { _wrapped.label }
    var amount: Int { _wrapped.amount }
    
    init(_ wrapped: MAReward) {
        self._wrapped = wrapped
        super.init()
    }
}


extension MAReward {
    var wrapped: Reward { BNMARewardWrapper(self) }
}
