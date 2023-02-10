//
//  SandboxApp.swift
//  Sandbox
//
//  Created by Stas Kochkin on 04.08.2022.
//

import SwiftUI
import Combine
import BidOn
import AppTrackingTransparency
import AppsFlyerLib
import AppsFlyerAdRevenue


@main
struct SandboxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        setupAppsFlyer()
        return true
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
        _ ad: BidOn.Ad,
        from type: BidOn.AdType,
        placement: String = ""
    ) {
        var additionalParameters: [AnyHashable: Any] = [:]
        additionalParameters[kAppsFlyerAdRevenueAdType] = type.rawValue
        additionalParameters[kAppsFlyerAdRevenueAdUnit] = ad.adUnitId
        additionalParameters[kAppsFlyerAdRevenuePlacement] = placement
        
        logAdRevenue(
            monetizationNetwork: ad.networkName,
            mediationNetwork: .appodeal,
            eventRevenue: ad.price as NSNumber,
            revenueCurrency: ad.currency,
            additionalParameters: additionalParameters
        )
    }
}
