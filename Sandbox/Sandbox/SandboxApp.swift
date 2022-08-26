//
//  SandboxApp.swift
//  Sandbox
//
//  Created by Stas Kochkin on 04.08.2022.
//

import SwiftUI
import BidOn


struct Constants {
    static let baseURL = "https://c3d5b3d8-63e7-4818-8ece-264c1df79e4f.mock.pstmn.io"
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
        
        BidOnSdk.logLevel = .verbose
        BidOnSdk.baseURL = Constants.baseURL
        BidOnSdk.initialize(appKey: "some app key") {
            withAnimation { [unowned self] in
                self.isInitialized = true
            }
        }
    
        return true
    }
}
