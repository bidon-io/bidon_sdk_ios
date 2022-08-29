//
//  SandboxApp.swift
//  Sandbox
//
//  Created by Stas Kochkin on 04.08.2022.
//

import SwiftUI
import BidOn
import AppTrackingTransparency


struct Constants {
    static let baseURL = "https://c3d5b3d8-63e7-4818-8ece-264c1df79e4f.mock.pstmn.io"
//    static let baseURL = "https://b.appbaqend.com"
    static let appKey = "3c53cae2cd969ecd82910e1f5610a3df24ea8b4b3ca52247"
}


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
        
        ATTrackingManager.requestTrackingAuthorization { _ in
            DispatchQueue.main.async {
                BidOnSdk.logLevel = .verbose
                BidOnSdk.baseURL = Constants.baseURL
                BidOnSdk.initialize(appKey: Constants.appKey) {
                    withAnimation { [unowned self] in
                        self.isInitialized = true
                    }
                }
            }
        }
         
        return true
    }
}
