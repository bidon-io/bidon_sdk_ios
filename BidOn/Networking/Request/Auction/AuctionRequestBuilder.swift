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
    var minPrice: Price { get }
    
    @discardableResult
    func withPlacement(_ placement: String) -> Self
    
    @discardableResult
    func withAuctionId(_ auctionId: String) -> Self
    
    @discardableResult
    func withMinPrice(_ minPrice: Price) -> Self
    
    init()
}


final class InterstitialAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!
    private(set) var minPrice: Price = .zero

    var adType: AdType { .interstitial }
    
    var adapters: AdaptersInfo {
        let interstitials: [InterstitialDemandSourceAdapter] = adaptersRepository.all()
        return AdaptersInfo(adapters: interstitials)
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
    
    @discardableResult
    func withMinPrice(_ minPrice: Price) -> Self {
        self.minPrice = minPrice
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placementId: placement,
            auctionId: auctionId,
            minPrice: minPrice,
            interstitial: AdObjectModel.InterstitialModel()
        )
    }
}


final class RewardedAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!
    private(set) var minPrice: Price = .zero

    var adType: AdType { .rewarded }
    
    var adapters: AdaptersInfo {
        let interstitials: [InterstitialDemandSourceAdapter] = adaptersRepository.all()
        return AdaptersInfo(adapters: interstitials)
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
    
    @discardableResult
    func withMinPrice(_ minPrice: Price) -> Self {
        self.minPrice = minPrice
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placementId: placement,
            auctionId: auctionId,
            minPrice: minPrice,
            rewarded: AdObjectModel.RewardedModel()
        )
    }
}


final class AdViewAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!
    private(set) var format: BannerFormat!
    private(set) var minPrice: Price = .zero

    var adType: AdType { .banner}
    
    var adapters: AdaptersInfo {
        let banners: [AdViewDemandSourceAdapter] = adaptersRepository.all()
        return AdaptersInfo(adapters: banners)
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
    
    @discardableResult
    func withFormat(_ format: BannerFormat) -> Self {
        self.format = format
        return self
    }
    
    @discardableResult
    func withMinPrice(_ minPrice: Price) -> Self {
        self.minPrice = minPrice
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placementId: placement,
            auctionId: auctionId,
            minPrice: minPrice,
            banner: AdObjectModel.BannerModel(
                format: format
            )
        )
    }
}
