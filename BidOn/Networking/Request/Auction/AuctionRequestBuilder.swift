//
//  AuctionRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation


protocol AuctionRequestBuilder: BaseRequestBuilder {
    var adObject: AdObjectModel { get }
    var adapters: AdaptersInfo { get }
    var adType: AdType { get }
    
    @discardableResult
    func withPlacement(_ placement: String) -> Self
    
    @discardableResult
    func withAuctionId(_ auctionId: String) -> Self
    
    init()
}


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


final class RewardedAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!

    var adType: AdType { .rewarded }
    
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
            rewarded: AdObjectModel.RewardedModel()
        )
    }
}


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
