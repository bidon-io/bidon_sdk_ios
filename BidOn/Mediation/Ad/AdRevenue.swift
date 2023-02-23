//
//  AdRevenue.swift
//  BidOn
//
//  Created by Stas Kochkin on 21.02.2023.
//

import Foundation


// MARK: Price
public typealias Price = Double

public extension Price {
    static let unknown: Price = 0.0
    
    var isUnknown: Bool {
        return isNaN || isZero || isInfinite
    }
}


internal extension Price {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    var pretty: String {
        isUnknown ? "-" : Price.formatter.string(from: self as NSNumber) ?? "-"
    }
}

// MARK: Currency
public typealias Currency = String

public extension Currency {
    static var `default` = "USD"
}


// MARK: Precision
@objc(BDNRevenuePrecision)
public enum RevenuePrecision: Int {
    case precise
    case estimated
}


// MARK: Ad Revenue
@objc(BDNAdRevenue)
public protocol AdRevenue {
    var revenue: Price { get }
    var precision: RevenuePrecision { get }
    var currency: Currency { get }
}


// MARK: Ad Revenue wrapper
public final class AdRevenueWrapper<Wrapped: AnyObject>: AdRevenue {
    public let revenue: Price
    public let precision: RevenuePrecision
    public let currency: Currency
    public let wrapped: Wrapped

    public init(
        revenue: Price,
        precision: RevenuePrecision,
        currency: Currency = .default,
        wrapped: Wrapped
    ) {
        self.revenue = revenue
        self.precision = precision
        self.currency = currency
        self.wrapped = wrapped
    }
    
    public convenience init(
        eCPM: Price,
        precision: RevenuePrecision = .estimated,
        wrapped: Wrapped
    ) {
        self.init(
            revenue: eCPM / 1000,
            precision: precision,
            wrapped: wrapped
        )
    }
}
