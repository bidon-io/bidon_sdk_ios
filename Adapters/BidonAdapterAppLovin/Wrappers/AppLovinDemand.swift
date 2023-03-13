//
//  AppLovinDemand.swift
//  BidonAdapterAppLovin
//
//  Created by Bidon Team on 21.02.2023.
//

import Foundation
import AppLovinSDK
import Bidon


protocol AppLovinDemand {
    func show(ad: AppLovinAdWrapper)
}


extension AppLovinDemand {
    var ad: AppLovinAdWrapper? {
        objc_getAssociatedObject(self, &AppLovinAdWrapper.adKey) as? AppLovinAdWrapper
    }
    
    func associate(ad: AppLovinAdWrapper) {
        objc_setAssociatedObject(self, &AppLovinAdWrapper.adKey, ad, .OBJC_ASSOCIATION_RETAIN)
    }
}


extension ALInterstitialAd: AppLovinDemand {
    func show(ad: AppLovinAdWrapper) {
        associate(ad: ad)
        show(ad.wrapped)
    }
}


extension ALAdView: AppLovinDemand {
    func show(ad: AppLovinAdWrapper) {
        associate(ad: ad)
        render(ad.wrapped)
    }
}


extension ALIncentivizedInterstitialAd {
    private static var lineItemKey: UInt8 = 0
    
    var lineItem: LineItem? {
        objc_getAssociatedObject(self, &ALIncentivizedInterstitialAd.lineItemKey) as? LineItem
    }
    
    private func associate(lineItem: LineItem) {
        objc_setAssociatedObject(self, &ALIncentivizedInterstitialAd.lineItemKey, lineItem, .OBJC_ASSOCIATION_RETAIN)
    }
    
    convenience init(lineItem: LineItem, sdk: ALSdk) {
        self.init(zoneIdentifier: lineItem.adUnitId, sdk: sdk)
        self.associate(lineItem: lineItem)
    }
}
