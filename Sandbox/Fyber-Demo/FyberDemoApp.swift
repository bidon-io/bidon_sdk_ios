//
//  FyberDemoApp.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 28.06.2022.
//

import SwiftUI
import FyberDecorator
import FairBidSDK
import BidMachineAdapter
import GoogleMobileAdsAdapter


extension FairBid {
    static let appId = "109613"
}


@main
struct FyberDemoApp: App {
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


final class ApplicationDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FairBid.bid.register(
            adapter: BidMachineDemandSourceAdapter.self,
            parameters: BidMachineParameters(sellerId: "1")
        )
        
        FairBid.bid.register(
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
        
        let options = FYBStartOptions()
        options.logLevel = .verbose
        
        FairBid.bid.start(
            withAppId: FairBid.appId,
            options: options
        )
        
        return true
    }
}
