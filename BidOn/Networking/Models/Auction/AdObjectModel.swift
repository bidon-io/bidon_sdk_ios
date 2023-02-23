//
//  AdObjectModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 10.08.2022.
//

import Foundation
import UIKit


struct AdObjectModel: Encodable {
    enum InterfaceOrientation: String, Encodable {
        case portrait
        case landscape
    }
    
    struct BannerModel: Encodable {
        var format: BannerFormat
    }
    
    struct InterstitialModel: Encodable {}
    
    struct RewardedModel: Encodable {}
    
    var orientation: InterfaceOrientation = .current
    var placementId: String
    var auctionId: String
    var pricefloor: Price
    var banner: BannerModel?
    var interstitial: InterstitialModel?
    var rewarded: RewardedModel?
}


extension AdObjectModel.InterfaceOrientation {
    init(_ isLandscape: Bool) {
        self = isLandscape ? .landscape : .portrait
    }
    
    static var current: AdObjectModel.InterfaceOrientation {
        let isLandscape = DispatchQueue.bd.blocking { UIApplication.shared.bd.isLandscape }
        return AdObjectModel.InterfaceOrientation(isLandscape)
    }
}


extension AdObjectModel.InterfaceOrientation {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue.uppercased())
    }
}
