//
//  DemandComparator.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 04.07.2022.
//

import Foundation


@objc(BDNAuctionComparator)
public protocol AuctionComparator {
    func compare(_ lhs: Ad, _ rhs: Ad) -> Bool
}


@objc(BDNHigherECPMAuctionComparator)
public final class HigherECPMAuctionComparator: NSObject, AuctionComparator {
    public func compare(_ lhs: Ad, _ rhs: Ad) -> Bool {
        return lhs.eCPM > rhs.eCPM
    }
}
