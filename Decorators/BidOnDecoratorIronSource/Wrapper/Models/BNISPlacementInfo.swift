//
//  ISPlacementInfo.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import IronSource
import BidOn


final class BNISPlacementInfoWrapper: NSObject, Reward {
    private let _wrapped: ISPlacementInfo
    
    var label: String { _wrapped.rewardName ?? ""}
    
    var amount: Int { _wrapped.rewardAmount?.intValue ?? 0 }
    
    var wrapped: AnyObject { _wrapped }
    
    init(_ wrapped: ISPlacementInfo) {
        self._wrapped = wrapped
        super.init()
    }
}


extension ISPlacementInfo {
    var wrapped: Reward {
        BNISPlacementInfoWrapper(self)
    }
    
    static func empty() -> ISPlacementInfo {
        return ISPlacementInfo(
            placement: "",
            reward: "",
            rewardAmount: 0
        )
    }
    
    static func unwrapped(_ reward: Reward) -> ISPlacementInfo {
        return (reward.wrapped as? ISPlacementInfo) ?? ISPlacementInfo(
            placement: "",
            reward: reward.label,
            rewardAmount: reward.amount as NSNumber
        )
    }
}
