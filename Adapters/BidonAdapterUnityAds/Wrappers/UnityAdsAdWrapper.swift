//
//  UnityAdsAdWrapper.swift
//  BidonAdapterUnityAds
//
//  Created by Bidon Team on 01.03.2023.
//

import Foundation
import Bidon
import UnityAds


final class UnityAdsAdWrapper: NSObject, Ad {
    var id: String { lineItem.adUnitId }
    var eCPM: Bidon.Price { lineItem.pricefloor }
    var adUnitId: String? { lineItem.adUnitId }
    var networkName: String { UnityAdsDemandSourceAdapter.identifier }
    var dsp: String? { nil }
    
    let lineItem: LineItem
    
    init(lineItem: LineItem) {
        self.lineItem = lineItem
        
        super.init()
    }
    
    override var hash: Int {
        return id.hash
    }
}


final class UnityAdsBannerAdWrapper: NSObject, Ad {
    var id: String { lineItem.adUnitId }
    var eCPM: Bidon.Price { lineItem.pricefloor }
    var adUnitId: String? { lineItem.adUnitId }
    var networkName: String { UnityAdsDemandSourceAdapter.identifier }
    var dsp: String? { nil }
    
    let lineItem: LineItem
    let bannerView: UADSBannerView
    
    init(
        lineItem: LineItem,
        bannerView: UADSBannerView
    ) {
        self.lineItem = lineItem
        self.bannerView = bannerView
        
        super.init()
    }
    
    override var hash: Int {
        return id.hash
    }
}
