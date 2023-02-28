//
//  GoogleMobileAdsAdRevenueWrapper-.swift
//  BidOnAdapterGoogleMobileAds
//
//  Created by Stas Kochkin on 23.02.2023.
//

import Foundation
import GoogleMobileAds
import BidOn


final class GoogleMobileAdsAdRevenueWrapper: NSObject, AdRevenue {
    var currency: BidOn.Currency { value.currencyCode }
    var revenue: Price { value.value.doubleValue }
    var precision: RevenuePrecision { RevenuePrecision(value.precision) }
    
    let value: GADAdValue
    
    init(_ value: GADAdValue) {
        self.value = value
        super.init()
    }
}


extension RevenuePrecision {
    init(_ precision: GADAdValuePrecision) {
        switch precision {
        case .precise: self = .precise
        default: self = .estimated
        }
    }
}
