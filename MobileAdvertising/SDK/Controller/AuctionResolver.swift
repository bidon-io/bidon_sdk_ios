//
//  DemandComparator.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


@objc
public protocol AuctionResolver {
    func resolve(
        ads: [Ad],
        resolution: @escaping (Ad?) -> ()
    )
}


@objc
public final class HigherRevenueAuctionResolver: NSObject, AuctionResolver {
    public func resolve(ads: [Ad], resolution: @escaping (Ad?) -> ()) {
        let ad = ads.sorted { $0.price > $1.price }.first
        resolution(ad)
    }
}
