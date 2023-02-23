//
//  AdvertisingServiceProvider.swift
//  Sandbox
//
//  Created by Stas Kochkin on 13.02.2023.
//

import Foundation
import UIKit
import Combine
import AppsFlyerLib
import AppsFlyerAdRevenue
import BidOn


final class AdServiceProvider: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    static let shared = AdServiceProvider()
    
    var service: AdService = AppodealAdService()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) {
        setupAppsFlyer()
    }
    
    private func setupAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = Constants.AppsFlyer.devKey
        AppsFlyerLib.shared().appleAppID = Constants.AppsFlyer.appId
        
        unowned let unownedSelf = self
        NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink(receiveValue: unownedSelf.receiveApplicationDidBecomeActive)
            .store(in: &cancellables)
    }
    
    private func receiveApplicationDidBecomeActive(notification: Notification) {
        AppsFlyerLib.shared().start()
        AppsFlyerAdRevenue.start()
    }
}


extension AppsFlyerAdRevenue {
    func log(
        adRevenue: AdRevenue,
        ad: BidOn.Ad,
        adType: BidOn.AdType,
        placement: String = ""
    ) {
        var additionalParameters: [AnyHashable: Any] = [:]
        additionalParameters[kAppsFlyerAdRevenueAdType] = adType.rawValue
        additionalParameters[kAppsFlyerAdRevenueAdUnit] = ad.adUnitId
        additionalParameters[kAppsFlyerAdRevenuePlacement] = placement
        
        logAdRevenue(
            monetizationNetwork: ad.networkName,
            mediationNetwork: .appodeal,
            eventRevenue: adRevenue.revenue as NSNumber,
            revenueCurrency: adRevenue.currency,
            additionalParameters: additionalParameters
        )
    }
}
