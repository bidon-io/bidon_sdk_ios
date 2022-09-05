//
//  BannerAuctionRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation


final class AdViewAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!

    var adType: AdType { .banner}
    
    var adapters: AdaptersInfo {
        let banners: [AdViewDemandSourceAdapter] = adaptersRepository.all()
        let mmps: [MobileMeasurementPartnerAdapter] = adaptersRepository.all()

        return AdaptersInfo(adapters: banners + mmps)
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
            banner: AdObjectModel.BannerModel()
        )
    }
}
