//
//  FullscreenImpression.swift
//  Bidon
//
//  Created by Stas Kochkin on 28.03.2023.
//

import Foundation


struct FullscreenImpression: Impression {
    var impressionId: String = UUID().uuidString
    var showTrackedAt: TimeInterval = .nan
    var clickTrackedAt: TimeInterval = .nan
    var rewardTrackedAt: TimeInterval = .nan
    
    var auctionId: String
    var auctionConfigurationId: Int
    var roundId: String
    var lineItem: LineItem?
    var adType: AdType
    var ad: DemandAd

    
    init<T: Bid>(bid: T) {
        self.auctionId = bid.auctionId
        self.auctionConfigurationId = bid.auctionConfigurationId
        self.roundId = bid.roundId
        self.lineItem = bid.lineItem
        self.adType = bid.adType
        self.ad = bid.ad
    }
}

