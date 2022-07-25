//
//  IronSource_DemoApp.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 10.07.2022.
//

import SwiftUI
import Combine
import IronSource
import IronSourceDecorator
import MobileAdvertising
import BidMachineAdapter
import GoogleMobileAdsAdapter
import AppsFlyerAdapter


fileprivate extension IronSource {
    static let appKey = "8545d445"
}


@main
struct IronSourceDemoApp: App {
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


final class ApplicationDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isInitialized: Bool = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        IronSource.bid.register(
            adapter: BidMachineDemandSourceAdapter.self,
            parameters: BidMachineParameters(
                sellerId: "1"
            )
        )

        IronSource.bid.register(
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
        
        IronSource.bid.register(
            adapter: AppsFlyerMobileMeasurementPartnerAdapter.self,
            parameters: AppsFlyerParameters(
                devKey: "some key",
                appId: "some app id"
            )
        )
        
        ISIntegrationHelper.validateIntegration()
        
        IronSource.bid.initializePublisher(
            IronSource.appKey,
            adUnits: [IS_BANNER, IS_INTERSTITIAL, IS_REWARDED_VIDEO]
        )
        .receive(on: DispatchQueue.main)
        .sink {
            withAnimation { [weak self] in
                self?.isInitialized = true
            }
        }
        .store(in: &cancellables)
        
        return true
    }
}
