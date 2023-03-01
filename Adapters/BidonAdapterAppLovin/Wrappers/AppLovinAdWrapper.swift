//
//  ALAdWrapper.swift
//  BidonAdapterAppLovin
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import AppLovinSDK
import Bidon


typealias AppLovinAdWrapper = AdWrapper<ALAd>
typealias AppLovinAdRevenueWrapper = AdRevenueWrapper<ALAd>


extension AppLovinAdWrapper {
    static var adKey: UInt8 = 0
    
    convenience init(
        lineItem: LineItem,
        ad: ALAd
    ) {
        self.init(
            id: ad.adIdNumber.stringValue,
            networkName: AppLovinDemandSourceAdapter.identifier,
            lineItem: lineItem,
            wrapped: ad
        )
    }
}


extension AppLovinAdRevenueWrapper {
    convenience init(_ wrapper: AppLovinAdWrapper) {
        self.init(
            eCPM: wrapper.eCPM,
            wrapped: wrapper.wrapped
        )
    }
}
