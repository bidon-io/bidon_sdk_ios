//
//  GADResponseWrapper.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import GoogleMobileAds
import MobileAdvertising


final internal class BNGADResponseInfoWrapper: NSObject, Ad {
    var id: String
    var price: Price
    var dsp: String
    var wrapped: AnyObject
    
    init(
        id: String,
        price: Price,
        dsp: String,
        wrapped: AnyObject
    ) {
        self.id = id
        self.price = price
        self.dsp = dsp
        self.wrapped = wrapped
        super.init()
    }
    
    convenience init(
        _ interstitial: GADInterstitialAd,
        item: LineItem
    ) {
        self.init(
            id: interstitial.responseInfo.responseIdentifier ?? item.adUnitId,
            price: item.pricefloor,
            dsp: interstitial.responseInfo.adNetworkClassName ?? "admob",
            wrapped: interstitial.responseInfo
        )
    }
}



