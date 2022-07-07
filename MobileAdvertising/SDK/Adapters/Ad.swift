//
//  AdProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


public typealias Price = Double


public extension Price {
    static let unknown = Double.nan
    
    var isUnknown: Bool {
        return isNaN || isZero || isInfinite
    }
}


@objc public protocol Ad {
    var id: String { get }
    var price: Price { get }
    var dsp: String { get }
    
    var wrapped: AnyObject { get }
}


internal struct HashableAd: Hashable  {
    var ad: Ad

    init(ad: Ad) {
        self.ad = ad
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ad.id)
    }
    
    static func == (lhs: HashableAd, rhs: HashableAd) -> Bool {
        return lhs.ad.id == rhs.ad.id
    }
}
