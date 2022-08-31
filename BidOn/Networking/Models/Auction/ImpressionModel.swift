//
//  ImpressionModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct ImpressionModel: Codable {
    var impressionId: String
    var auctionId: String
    var auctionConfigurationId: Int
    var demandId: String
    var adUnitId: String?
    var format: String
    var status: Int
    var ecpm: Price

    init(_ imp: Impression) {
        self.impressionId = imp.impressionId
        self.auctionId = imp.auctionId
        self.auctionConfigurationId = imp.auctionConfigurationId
        self.demandId = imp.ad.networkName
        self.format = ""
        self.adUnitId = imp.ad.adUnitId
        self.status = 0
        self.ecpm = imp.ad.price
    }
}
