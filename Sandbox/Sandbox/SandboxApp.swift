//
//  SandboxApp.swift
//  Sandbox
//
//  Created by Stas Kochkin on 04.08.2022.
//

import SwiftUI
import BidOn


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
    @Published var isInitialized: Bool = false
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        BidOnSdk.logLevel = .verbose
        BidOnSdk.baseURL = "https://07f690ed-b816-459b-82fd-212270eb950a.mock.pstmn.io"
        BidOnSdk.initialize(appKey: "some app key") {
            withAnimation { [unowned self] in
                self.isInitialized = true
            }
        }
    
        return true
    }
}
