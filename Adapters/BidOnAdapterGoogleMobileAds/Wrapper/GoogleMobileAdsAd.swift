//
//  GoogleMobileAd.swift
//  BidOnAdapterGoogleMobileAds
//
//  Created by Stas Kochkin on 30.08.2022.
//

import Foundation
import GoogleMobileAds
import BidOn


typealias GoogleMobileAdsAd = DirectAdWrapper<GADResponseInfo>


extension GoogleMobileAdsAd {
    convenience init(
        _ lineItem: LineItem,
        _ response: GADResponseInfo
    ) {
        self.init(
            response.responseIdentifier ?? lineItem.adUnitId,
            "admob",
            nil,
            lineItem,
            response
        )
    }
}
