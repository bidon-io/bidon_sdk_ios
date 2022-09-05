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


struct Constants {
    static let baseURL = "https://b.appbaqend.com"
    static let appKey = "3c53cae2cd969ecd82910e1f5610a3df24ea8b4b3ca52247"
}


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
            baseURL: "https://b.appbaqend.com"
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
        baseURL: "https://b.appbaqend.com"
    )
    
    func initialize() {
        withAnimation { [unowned self] in
            self.isInitializing = true
        }
        
        BidOnSdk.baseURL = host.baseURL
        BidOnSdk.logLevel = logLevel
        BidOnSdk.initialize(appKey: Constants.appKey) {
            withAnimation { [unowned self] in
                self.isInitializing = false
                self.isInitialized = true
            }
        }
    }
}


