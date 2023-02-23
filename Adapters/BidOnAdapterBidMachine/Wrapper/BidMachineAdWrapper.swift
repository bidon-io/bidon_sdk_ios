//
//  AuctionInfoWrapper.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 10.02.2023.
//

import Foundation
import BidOn
import BidMachine


typealias BidMachineAdWrapper<T: BidMachineAdProtocol> = AdWrapper<T>
typealias BidMachineInterstitialAdWrapper = BidMachineAdWrapper<BidMachineInterstitial>
typealias BidMachineRewardedAdWrapper = BidMachineAdWrapper<BidMachineRewarded>
typealias BidMachineBannerAdWrapper = BidMachineAdWrapper<BidMachineBanner>

typealias BidMachineAdRevenueWrapper = AdRevenueWrapper<BidMachineAdProtocol>


extension AdWrapper where Wrapped: BidMachineAdProtocol  {
    convenience init(_ ad: Wrapped) {
        self.init(
            id: ad.auctionInfo.bidId,
            eCPM: ad.auctionInfo.price,
            networkName: BidMachineDemandSourceAdapter.identifier,
            dsp: ad.auctionInfo.demandSource,
            wrapped: ad
        )
    }
}


extension BidMachineAdRevenueWrapper {
    convenience init(_ ad: BidMachineAdProtocol) {
        self.init(
            eCPM: ad.auctionInfo.price,
            precision: .precise,
            wrapped: ad
        )
    }
}
