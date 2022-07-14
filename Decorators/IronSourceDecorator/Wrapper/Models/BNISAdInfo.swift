//
//  BNISAdInfo.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


final class BNISAdInfo: NSObject, Ad {
    let _wrapped: ISAdInfo
    
    var id: String { _wrapped.auction_id }
    var price: Price { _wrapped.revenue.doubleValue }
    var dsp: String { _wrapped.ad_network }
    
    var wrapped: AnyObject { _wrapped }
    
    init(_ wrapped: ISAdInfo) {
        self._wrapped = wrapped
    }
}


extension ISAdInfo {
    var wrapped: Ad { BNISAdInfo(self) }
}


typealias ISAdInfoSet = Set<ISAdInfo>


extension ISAdInfoSet {
    func info(with pricefloor: Price) -> ISAdInfo? {
        guard !pricefloor.isUnknown else {
            return self.max { $0.revenue.doubleValue < $1.revenue.doubleValue }
        }
    
        return first { $0.revenue.doubleValue >= pricefloor }
    }
}
