//
//  EmptyReward.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import MobileAdvertising


internal final class EmptyReward: NSObject, Reward {
    var wrapped: AnyObject { NSNull() }
    
    var amount: Int = 0
    var label: String = ""
}
