//
//  BidMachineEmptyReward.swift
//  BidonAdapterBidMachine
//
//  Created by Stas Kochkin on 01.06.2023.
//

import Foundation
import Bidon


internal typealias BidMachineEmptyReward = RewardWrapper<NSNull>

 
extension BidMachineEmptyReward {
    convenience init() {
        self.init(
            label: "",
            amount: .zero,
            wrapped: NSNull()
        )
    }
}
