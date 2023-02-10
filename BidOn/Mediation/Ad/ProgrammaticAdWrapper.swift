//
//  ProgrammaticAdWrapper.swift
//  BidOn
//
//  Created by Stas Kochkin on 30.08.2022.
//

import Foundation


public final class ProgrammaticAdWrapper<Wrapped: AnyObject>: Ad {
    public let id: String
    
    public let price: Price
    
    public let currency: Currency
    
    public let networkName: String
    
    public let dsp: String?
    
    public let wrapped: Wrapped
    
    public let adUnitId: String? = nil
    
    public let pricePrecision: PricePrecision = .programmatic
    
    public init(
        id: String,
        networkName: String,
        dsp: String?,
        price: Price,
        wrapped: Wrapped
    ) {
        self.id = id
        self.price = price
        self.currency = .default
        self.networkName = networkName
        self.dsp = dsp
        self.wrapped = wrapped
    }
}


extension ProgrammaticAdWrapper: CustomStringConvertible {
    public var description: String {
        return "Programmatic ad #\(id), network: \(networkName), dsp: \(dsp ?? "-"), revenue: \(price) \(currency). Wrapped \(wrapped)"
    }
}
