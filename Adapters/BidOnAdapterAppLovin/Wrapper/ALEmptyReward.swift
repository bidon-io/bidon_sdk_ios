//
//  ALEmptyReward.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation
import BidOn


final class ALEmptyReward: NSObject, Reward {
    let label: String = ""
    let amount: Int = 0
    let wrapped: AnyObject = NSNull()
}
