//
//  GADResponseWrapper.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import GoogleMobileAds
import MobileAdvertising


protocol ResponseInfoProvider {
    var info: GADResponseInfo? { get }
}

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
        _ provider: ResponseInfoProvider,
        item: LineItem
    ) {
        self.init(
            id: provider.info?.responseIdentifier ?? item.adUnitId,
            price: item.pricefloor,
            dsp: provider.info?.adNetworkClassName ?? "admob",
            wrapped: provider.info ?? NSNull()
        )
    }
}


extension GADBannerView: ResponseInfoProvider {
    var info: GADResponseInfo? { responseInfo }
}



