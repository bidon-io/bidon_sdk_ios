//
//  AuctionInfoWrapper.swift
//  BidonAdapterBidMachine
//
//  Created by Bidon Team on 10.02.2023.
//

import Foundation
import Bidon
import BidMachine


final class BidMachineAdDemand<Ad: BidMachineAdProtocol>: NSObject, DemandAd {
    var id: String { ad.auctionInfo.bidId }
    var networkName: String { BidMachineDemandSourceAdapter.identifier }
    var dsp: String? { ad.auctionInfo.demandSource }
    var eCPM: Price { ad.auctionInfo.price }
    
    let ad: Ad
    
    init(_ ad: Ad) {
        self.ad = ad
        super.init()
    }
}

typealias BidMachineAdRevenueWrapper = AdRevenueWrapper<BidMachineAdProtocol>

extension BidMachineAdRevenueWrapper {
    convenience init(_ ad: BidMachineAdProtocol) {
        self.init(
            eCPM: ad.auctionInfo.price,
            precision: .precise,
            wrapped: ad
        )
    }
}
