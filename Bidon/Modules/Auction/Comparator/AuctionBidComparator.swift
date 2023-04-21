//
//  AuctionBidComparator.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


protocol AuctionBidComparator {
    func compare<T: Bid>(_ lhs: T, _ rhs: T) -> Bool
}
