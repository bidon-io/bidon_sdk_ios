//
//  InitializationViewModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation
import Combine
import BidOn
import BidOnAdapterAppLovin
import BidOnAdapterBidMachine
import BidOnAdapterGoogleMobileAds
import SwiftUI


final class InitializationViewModel: ObservableObject, AdResponder {
    enum InitializationState {
        case idle
        case initilizing
        case initialized
    }
    
    let permissions: [PermissionView.Model] = [
        AppTrackingTransparencyPermission(),
        LocationPermission()
    ].map { (permission: Permission) -> PermissionView.Model in
        PermissionView.Model(permission: permission)
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
    
    @Published var initializationState: InitializationState = .idle
    
    @Published var logLevel: LogLevel = .debug {
        didSet { adService.logLevel = logLevel }
    }
    
    @Published var host = HostView.Model(
        name: "Production",
        baseURL: Constants.BidOn.baseURL
    ) {
        didSet { adService.bidOnURL = host.baseURL }
    }
    
    @Published var mediation: Mediation = .appodeal {
        didSet {
            switch mediation {
            case .none:
                AdServiceProvider.shared.service = RawAdService()
            case .appodeal:
                AdServiceProvider.shared.service = AppodealAdService()
            }
        }
    }
    
    @Published var adapters: [BidOn.Adapter] = .default()
    
    @MainActor
    func initialize() async {
        update(.initilizing)
        await adService.initialize()
        update(.initialized)
    }
    
    func registerDefaultAdapters() {
        BidOnSdk.registerDefaultAdapters()
        withAnimation { [unowned self] in
            self.adapters = .default()
        }
    }
    
    private func update(
        _ state: InitializationState,
        animation: Animation = .default
    ) {
        withAnimation(animation) { [unowned self] in
            self.initializationState = state
        }
    }
}


fileprivate extension Array where Element == BidOn.Adapter {
    static func `default`() -> [Element] {
        return [
            AppLovinDemandSourceAdapter(),
            BidMachineDemandSourceAdapter(),
            GoogleMobileAdsDemandSourceAdapter()
        ]
    }
}
