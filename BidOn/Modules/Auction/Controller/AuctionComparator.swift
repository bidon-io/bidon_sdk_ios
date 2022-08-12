//
//  DemandComparator.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


@objc
public protocol AuctionComparator {
    func compare(_ lhs: Ad, _ rhs: Ad) -> Bool
}


@objc
public final class HigherPriceAuctionComparator: NSObject, AuctionComparator {
    public func compare(_ lhs: Ad, _ rhs: Ad) -> Bool {
        return lhs.price > rhs.price
    }
}
