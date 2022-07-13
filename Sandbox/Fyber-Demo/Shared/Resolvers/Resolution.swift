//
//  Resolution.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 13.07.2022.
//

import Foundation
import MobileAdvertising


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

