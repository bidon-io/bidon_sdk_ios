//
//  RewardedAuctionRequestBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 02.06.2023.
//

import Foundation


final class RewardedAuctionRequestBuilder: BaseAuctionRequestBuilder<RewardedAdTypeContext> {    
    override var adapters: AdaptersInfo {
        let adapters: [Adapter] =
        adaptersRepository.all(of: DirectRewardedAdDemandSourceAdapter.self) +
        adaptersRepository.all(of: BiddingRewardedAdDemandSourceAdapter.self)
        
        return AdaptersInfo(adapters: adapters)
    }
    
    override var adObject: AuctionRequestAdObject {
        return AuctionRequestAdObject(
            auctionId: auctionId,
            auctionKey: auctionKey,
            pricefloor: pricefloor,
            rewarded: RewardedAdTypeContextModel(context),
            demands: demands
        )
    }
}
