//
//  AuctionInfoWrapper.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 10.02.2023.
//

import Foundation
import BidOn
import BidMachine


typealias AuctionResponseWrapper = ProgrammaticAdWrapper<BidMachineAuctionResponseProtocol>


extension AuctionResponseWrapper {
    convenience init(_ auctionResponse: BidMachineAuctionResponseProtocol) {
        self.init(
            id: auctionResponse.bidId,
            networkName: BidMachineDemandSourceAdapter.identifier,
            dsp: auctionResponse.demandSource,
            price: auctionResponse.price,
            wrapped: auctionResponse
        )
    }
}

