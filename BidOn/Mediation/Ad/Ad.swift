//
//  AdProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


public typealias Price = Double
public typealias Currency = String


public extension Price {
    static let unknown: Price = 0
    
    var isUnknown: Bool {
        return isNaN || isZero || isInfinite
    }
}


public extension Currency {
    static var `default` = "USD"
}


@objc(BNPricePrecision)
public enum PricePrecision: Int {
    case programmatic
    case direct
}

@objc(BNAd)
public protocol Ad {
    var id: String { get }
    var adUnitId: String? { get }
    var price: Price { get }
    var pricePrecision: PricePrecision { get }
    var currency: Currency { get }
    var networkName: String { get }
    var dsp: String? { get }
}
