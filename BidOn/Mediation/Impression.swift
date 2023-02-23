//
//  Impression.swift
//  BidOn
//
//  Created by Stas Kochkin on 30.08.2022.
//

import Foundation


protocol Impression {
    var impressionId: String { get }
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var ad: Ad { get }
}
