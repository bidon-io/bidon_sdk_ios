//
//  AdRevenueWrapper.swift
//  Bidon
//
//  Created by Stas Kochkin on 28.03.2023.
//

import Foundation


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
