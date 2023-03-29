//
//  DemandComparator.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 04.07.2022.
//

import Foundation


protocol AuctionComparator {
    func compare<T: Bid>(_ lhs: T, _ rhs: T) -> Bool
}


struct HigherECPMAuctionComparator: AuctionComparator {
    func compare<T>(_ lhs: T, _ rhs: T) -> Bool where T : Bid {
        return lhs.eCPM > rhs.eCPM
    }
}
