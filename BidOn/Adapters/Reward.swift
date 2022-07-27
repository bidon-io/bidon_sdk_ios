//
//  Reward.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation


@objc public protocol Reward {
    var label: String { get }
    var amount: Int { get }
    
    var wrapped: AnyObject { get }
}
