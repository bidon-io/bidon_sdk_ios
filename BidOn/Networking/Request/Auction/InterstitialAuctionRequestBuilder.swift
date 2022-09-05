//
//  InterstitialAuctionRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class InterstitialAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!

    var adType: AdType { .interstitial }
    
    var adapters: AdaptersInfo {
        let interstitials: [InterstitialDemandSourceAdapter] = adaptersRepository.all()
        let mmps: [MobileMeasurementPartnerAdapter] = adaptersRepository.all()

        return AdaptersInfo(adapters: interstitials + mmps)
    }
    
    @discardableResult
    func withPlacement(_ placement: String) -> Self {
        self.placement = placement
        return self
    }
    
    @discardableResult
    func withAuctionId(_ auctionId: String) -> Self {
        self.auctionId = auctionId
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placement: placement,
            auctionId: auctionId,
            interstitial: AdObjectModel.InterstitialModel()
        )
    }
}
