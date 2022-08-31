//
//  Demand.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


protocol Demand {
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var ad: Ad { get }
    var provider: DemandProvider { get }
}