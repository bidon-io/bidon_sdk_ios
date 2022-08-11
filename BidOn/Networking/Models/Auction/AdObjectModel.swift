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
        
    }
    
    struct InterstitialModel: Encodable {
        enum Format: Int, Encodable {
            case `static` = 0
            case video = 1
        }
        var formats: [Format] = [.static, .video]
    }
    
    struct RewardedModel: Encodable {
        
    }
    
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
        let isLandscape = try? DispatchQueue.bd.perform { UIApplication.shared.bd.isLandscape }
        return isLandscape.map { AdObjectModel.InterfaceOrientation($0) } ?? .portrait
    }
}
