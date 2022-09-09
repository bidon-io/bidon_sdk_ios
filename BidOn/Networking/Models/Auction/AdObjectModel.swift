//
//  AdObjectModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 10.08.2022.
//

import Foundation
import UIKit


struct AdObjectModel: Encodable {
    enum InterfaceOrientation: Int, Encodable {
        case portrait = 0
        case landscape = 1
    }
    
    struct BannerModel: Encodable {
        var format: AdViewFormat
    }
    
    struct InterstitialModel: Encodable {}
    
    struct RewardedModel: Encodable {}
    
    var orientation: InterfaceOrientation = .current
    var placement: String
    var auctionId: String
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
