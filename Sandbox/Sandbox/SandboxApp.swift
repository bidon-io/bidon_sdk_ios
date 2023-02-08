//
//  SandboxApp.swift
//  Sandbox
//
//  Created by Stas Kochkin on 04.08.2022.
//

import SwiftUI
import BidOn
import AppTrackingTransparency

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
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }
}



class ViewController: UIViewController {
    var banner: BidOn.Banner!
    
    func loadBanner() {
        banner = BidOn.Banner(frame: .zero)
        banner.rootViewController = self
        banner.format = .banner
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.heightAnchor.constraint(equalToConstant: 50),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            banner.leftAnchor.constraint(equalTo: view.leftAnchor),
            banner.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        banner.loadAd(with: 0.1)
    }
}


extension ViewController: BidOn.AdViewDelegate {
    func adView(_ adView: UIView & BidOn.AdView, willPresentScreen ad: BidOn.Ad) {}
    
    func adView(_ adView: UIView & BidOn.AdView, didDismissScreen ad: BidOn.Ad) {}
    
    func adView(_ adView: UIView & BidOn.AdView, willLeaveApplication ad: BidOn.Ad) {}
    
    func adObject(_ adObject: BidOn.AdObject, didLoadAd ad: BidOn.Ad) {}
    
    func adObject(_ adObject: BidOn.AdObject, didFailToLoadAd error: Error) {}
}
