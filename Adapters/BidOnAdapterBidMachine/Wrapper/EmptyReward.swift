//
//  EmptyReward.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 10.02.2023.
//

import Foundation
import GoogleMobileAds
import BidOn

typealias EmptyReward = RewardWrapper<NSNull>
 
extension EmptyReward {
    convenience init() {
        self.init(
            label: "",
            amount: .zero,
            wrapped: NSNull()
        )
    }
}
