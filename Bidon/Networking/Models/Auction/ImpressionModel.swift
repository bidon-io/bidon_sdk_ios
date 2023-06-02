//
//  ImpressionModel.swift
//  Bidon
//
//  Created by Bidon Team on 31.08.2022.
//

import Foundation


struct ImpressionModel: Encodable {
    var impressionId: String
    var auctionId: String
    var auctionConfigurationId: Int
    var demandId: String
    var adUnitId: String?
    var ecpm: Price
    var banner: AdViewAucionContextModel?
    var interstitial: InterstitialAuctionContextModel?
    var rewarded: RewardedAuctionContextModel?
    
    enum CodingKeys: String, CodingKey {
        case impressionId = "imp_id"
        case auctionId = "auction_id"
        case auctionConfigurationId = "auction_configuration_id"
        case demandId = "demand_id"
        case adUnitId = "ad_unit_id"
        case ecpm = "ecpm"
        case banner = "banner"
        case interstitial = "interstitial"
        case rewarded = "rewarded"
    }
    
    init(
        _ imp: Impression,
        banner: AdViewAucionContextModel? = nil,
        interstitial: InterstitialAuctionContextModel? = nil,
        rewarded: RewardedAuctionContextModel? = nil
    ) {
        self.impressionId = imp.impressionId
        self.auctionId = imp.auctionId
        self.auctionConfigurationId = imp.auctionConfigurationId
        self.demandId = imp.ad.networkName
        self.adUnitId = imp.lineItem?.adUnitId
        self.ecpm = imp.eCPM
        self.banner = banner
        self.interstitial = interstitial
        self.rewarded = rewarded
    }
}
