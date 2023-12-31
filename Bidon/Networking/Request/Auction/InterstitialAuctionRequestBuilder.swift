//
//  InterstitialAuctionRequestBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 02.06.2023.
//

import Foundation


final class InterstitialAuctionRequestBuilder: BaseAuctionRequestBuilder<InterstitialAdTypeContext> {
    override var adapters: AdaptersInfo {
        let programmatic: [ProgrammaticInterstitialDemandSourceAdapter] = adaptersRepository.all()
        let direct: [DirectInterstitialDemandSourceAdapter] = adaptersRepository.all()
        let bidding: [BiddingInterstitialDemandSourceAdapter] = adaptersRepository.all()
        let adapters: [Adapter] = programmatic + direct + bidding
        return AdaptersInfo(adapters: adapters)
    }
    
    override var adObject: AuctionRequestAdObject {
        AuctionRequestAdObject(
            auctionId: auctionId,
            pricefloor: pricefloor,
            interstitial: InterstitialAdTypeContextModel(context)
        )
    }
}
