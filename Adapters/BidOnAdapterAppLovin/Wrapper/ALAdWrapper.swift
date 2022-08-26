//
//  ALAdWrapper.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import AppLovinSDK
import BidOn


final class ALAdWrapper: NSObject, Ad {
    private let _wrapped: ALAd
    
    var wrapped: AnyObject { _wrapped }
    
    let currency: Currency = .default
    
    let networkName: String = "applovin"
    
    var id: String {
        _wrapped.adIdNumber.stringValue
    }
    
    var price: Price
    
    var dsp: String? { nil }
    
    init(_ wrapped: ALAd, price: Price) {
        self._wrapped = wrapped
        self.price = price
        super.init()
    }
}
