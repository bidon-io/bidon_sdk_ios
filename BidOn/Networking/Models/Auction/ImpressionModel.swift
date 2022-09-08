//
//  ImpressionModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct ImpressionModel: Encodable {
    var impressionId: String
    var auctionId: String
    var auctionConfigurationId: Int
    var demandId: String
    var adUnitId: String?
    var ecpm: Price
    var banner: AdObjectModel.BannerModel?
    var interstitial: AdObjectModel.InterstitialModel?
    var rewarded: AdObjectModel.RewardedModel?
    
    init(
        _ imp: Impression,
        banner: AdObjectModel.BannerModel? = nil,
        interstitial: AdObjectModel.InterstitialModel? = nil,
        rewarded: AdObjectModel.RewardedModel? = nil
    ) {
        self.impressionId = imp.impressionId
        self.auctionId = imp.auctionId
        self.auctionConfigurationId = imp.auctionConfigurationId
        self.demandId = imp.ad.networkName
        self.adUnitId = imp.ad.adUnitId
        self.ecpm = imp.ad.price
        self.banner = banner
        self.interstitial = interstitial
        self.rewarded = rewarded
    }
}
