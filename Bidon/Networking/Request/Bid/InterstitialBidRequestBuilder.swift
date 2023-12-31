//
//  InterstitialBidRequestBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 02.06.2023.
//

import Foundation



final class InterstitialBidRequestBuilder: BaseBidRequestBuilder<InterstitialAdTypeContext> {    
    override var imp: BidRequestImp {
        BidRequestImp(
            bidfloor: bidfloor,
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            auctionConfigurationUid: auctionConfigurationUid,
            roundId: roundId,
            interstitial: InterstitialAdTypeContextModel(context),
            demands: demands
        )
    }
}
