//
//  BNBidMachineAdWrapper.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation
import BidMachine
import BidOn


typealias BidMachineAd = ProgrammaticAdWrapper<BDMAdProtocol>


extension BidMachineAd {
    convenience init(_ ad: BDMAdProtocol) {
        self.init(
            ad.auctionInfo.bidID ?? ad.auctionInfo.description,
            BidMachineDemandSourceAdapter.identifier,
            ad.auctionInfo.demandSource,
            ad.auctionInfo.price?.doubleValue ?? .unknown,
            ad
        )
    }
}
