//
//  InitializationViewModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation
import Combine
import BidOn
import SwiftUI


final class InitializationViewModel: ObservableObject {
    let permissions: [PermissionView.Model] = [
        AppTrackingTransparencyPermission(),
        LocationPermission()
    ].map { (permission: Permission) -> PermissionView.Model in
            .init(permission: permission)
    }
    
    let hosts: [HostView.Model] = [
        .init(
            name: "Production",
            baseURL: Constants.BidOn.baseURL
        ),
        .init(
            name: "Mock",
            baseURL: "https://c3d5b3d8-63e7-4818-8ece-264c1df79e4f.mock.pstmn.io"
        )
    ]
    
    @Published var isInitialized: Bool = false
    
    @Published var isInitializing: Bool = false
    
    @Published var logLevel: BidOn.Logger.Level = .verbose
    
    @Published var host = HostView.Model(
        name: "Production",
        baseURL: Constants.BidOn.baseURL
    )
    
    func initialize() {
        withAnimation { [unowned self] in
            self.isInitializing = true
        }
        // Register default adapters
        BidOnSdk.registerDefaultAdapters()
        // Configure BidOn
        BidOnSdk.baseURL = host.baseURL
        BidOnSdk.logLevel = logLevel
        // Initialize
        BidOnSdk.initialize(appKey: Constants.BidOn.appKey) {
            withAnimation { [unowned self] in
                self.isInitializing = false
                self.isInitialized = true
            }
        }
    }
}


