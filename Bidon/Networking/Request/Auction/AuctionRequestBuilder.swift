//
//  AuctionRequestBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 05.09.2022.
//

import Foundation


protocol AuctionRequestBuilder: BaseRequestBuilder {
    var adObject: AdObjectModel { get }
    var adapters: AdaptersInfo { get }
    var adType: AdType { get }
    var pricefloor: Price { get }
    
    @discardableResult
    func withPlacement(_ placement: String) -> Self
    
    @discardableResult
    func withAuctionId(_ auctionId: String) -> Self
    
    @discardableResult
    func withPricefloor(_ pricefloor: Price) -> Self
    
    init()
}


final class InterstitialAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!
    private(set) var pricefloor: Price = .zero

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
    func withPricefloor(_ pricefloor: Price) -> Self {
        self.pricefloor = pricefloor
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placementId: placement,
            auctionId: auctionId,
            pricefloor: pricefloor,
            interstitial: AdObjectModel.InterstitialModel()
        )
    }
}


final class RewardedAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!
    private(set) var pricefloor: Price = .zero

    var adType: AdType { .rewarded }
    
    var adapters: AdaptersInfo {
        let interstitials: [RewardedAdDemandSourceAdapter] = adaptersRepository.all()
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
    func withPricefloor(_ pricefloor: Price) -> Self {
        self.pricefloor = pricefloor
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placementId: placement,
            auctionId: auctionId,
            pricefloor: pricefloor,
            rewarded: AdObjectModel.RewardedModel()
        )
    }
}


final class AdViewAuctionRequestBuilder: BaseRequestBuilder, AuctionRequestBuilder {
    private(set) var placement: String!
    private(set) var auctionId: String!
    private(set) var format: BannerFormat!
    private(set) var pricefloor: Price = .zero

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
    func withPricefloor(_ pricefloor: Price) -> Self {
        self.pricefloor = pricefloor
        return self
    }
    
    var adObject: AdObjectModel {
        AdObjectModel(
            placementId: placement,
            auctionId: auctionId,
            pricefloor: pricefloor,
            banner: AdObjectModel.BannerModel(
                format: format
            )
        )
    }
}
