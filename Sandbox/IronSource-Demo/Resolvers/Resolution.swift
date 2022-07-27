//
//  Resolution.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import BidOn


enum Resolution: String, CaseIterable {
    case `default` = "Higher Revenue"
    case manual = "Manual"
    
    var resolver: AuctionResolver {
        switch self {
        case .default: return HigherRevenueAuctionResolver()
        case .manual: return ManualAuctionResolver()
        }
    }
}
