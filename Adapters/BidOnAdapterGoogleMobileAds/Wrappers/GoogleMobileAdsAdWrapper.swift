//
//  GoogleMobileAd.swift
//  BidOnAdapterGoogleMobileAds
//
//  Created by Stas Kochkin on 30.08.2022.
//

import Foundation
import GoogleMobileAds
import BidOn


protocol GoogleMobileAdsAdObject: AnyObject {
    var info: GADResponseInfo? { get }
    var paidEventHandler: GADPaidEventHandler? { get set }
}


final class GoogleMobileAdsAdWrapper<AdOject: GoogleMobileAdsAdObject>: NSObject, Ad {
    var id: String { adObject.info?.responseIdentifier ?? lineItem.adUnitId }
    var eCPM: BidOn.Price { lineItem.pricefloor }
    var adUnitId: String? { lineItem.adUnitId }
    var networkName: String { GoogleMobileAdsDemandSourceAdapter.identifier }
    var dsp: String? { nil }
    
    let lineItem: LineItem
    let adObject: AdOject
    
    init(
        lineItem: LineItem,
        adObject: AdOject
    ) {
        self.lineItem = lineItem
        self.adObject = adObject
    }
}


extension GADInterstitialAd: GoogleMobileAdsAdObject {
    var info: GADResponseInfo? { responseInfo }
}


extension GADRewardedAd: GoogleMobileAdsAdObject {
    var info: GADResponseInfo? { responseInfo }
}


extension GADBannerView: GoogleMobileAdsAdObject {
    var info: GADResponseInfo? { responseInfo }
}
