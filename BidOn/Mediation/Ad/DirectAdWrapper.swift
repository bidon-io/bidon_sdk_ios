//
//  DirectAdWrapper.swift
//  BidOn
//
//  Created by Stas Kochkin on 30.08.2022.
//

import Foundation


public final class DirectAdWrapper<Wrapped: AnyObject>: Ad {
    public let id: String
    
    public let price: Price
    
    public let currency: Currency
    
    public let networkName: String
    
    public let dsp: String?
    
    public let wrapped: Wrapped
    
    public let adUnitId: String?
    
    public let pricePrecision: PricePrecision = .direct
    
    public init(
        id: String,
        networkName: String,
        dsp: String?,
        lineItem: LineItem,
        wrapped: Wrapped
    ) {
        self.id = id
        self.price = lineItem.pricefloor
        self.adUnitId = lineItem.adUnitId
        self.currency = .default
        self.networkName = networkName
        self.dsp = dsp
        self.wrapped = wrapped
    }
}


extension DirectAdWrapper: CustomStringConvertible {
    public var description: String {
        return "Direct ad #\(id), network: \(networkName), dsp: \(dsp ?? "-"), ad unit id: \(adUnitId!), revenue: \(price) \(currency). Wrapped \(wrapped)"
    }
}

