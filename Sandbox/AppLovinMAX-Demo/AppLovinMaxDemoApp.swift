//
//  AppLovinMAX_DemoApp.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 28.06.2022.
//

import SwiftUI
import AppLovinSDK
import AppLovinDecorator
import BidMachineAdapter
import GoogleMobileAdsAdapter
import MobileAdvertising


let applovin = ALSdk.shared(
    withKey: "05TMDQ5tZabpXQ45_UTbmEGNUtVAzSTzT6KmWQc5_CuWdzccS4DCITZoL3yIWUG3bbq60QC_d4WF28tUC4gVTF"
)!

var resolver: AuctionResolver = ManualAuctionResolver()


@main
struct AppLovinMaxDemoApp: App {
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


final class ApplicationDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var isInitialized: Bool = false
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        applovin.mediationProvider = ALMediationProviderMAX
        applovin.bid.register(
            adapter: BidMachineDemandSourceAdapter.self,
            parameters: BidMachineParameters(
                sellerId: "1"
            )
        )
        
        applovin.bid.register(
            adapter: GoogleMobileAdsDemandSourceAdapter.self,
            parameters: GoogleMobileAdsParameters(
                interstitial: [
                    LineItem(0.1, adUnitId: "ca-app-pub-3940256099942544/4411468910"),
                    LineItem(0.05, adUnitId: "ca-app-pub-3940256099942544/4411468910"),
                ],
                rewardedAd: [
                    LineItem(0.1, adUnitId: "ca-app-pub-3940256099942544/1712485313"),
                    LineItem(0.05, adUnitId: "ca-app-pub-3940256099942544/1712485313"),
                ],
                banner: [
                    LineItem(0.1, adUnitId: "ca-app-pub-3940256099942544/2934735716"),
                    LineItem(0.05, adUnitId: "ca-app-pub-3940256099942544/2934735716")
                ]
            )
        )
        
        applovin.bid.initializeSdk() { configuration in
            withAnimation { [unowned self] in
                self.isInitialized = true
            }
        }
        
        return true
    }
}
