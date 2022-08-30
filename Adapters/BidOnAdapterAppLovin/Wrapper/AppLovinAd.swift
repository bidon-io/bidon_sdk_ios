//
//  ALAdWrapper.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import AppLovinSDK
import BidOn


typealias AppLovinAd = DirectAdWrapper<ALAd>

extension AppLovinAd {
    convenience init(_ lineItem: LineItem, _ ad: ALAd) {
        self.init(
            ad.adIdNumber.stringValue,
            "applovin",
            nil,
            lineItem,
            ad
        )
    }
}
