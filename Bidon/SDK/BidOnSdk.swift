//
//  SDK.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 15.06.2022.
//

import Foundation
import UIKit


@objc(BDNSdk)
public final class BidonSdk: NSObject {
    internal lazy var adaptersRepository = AdaptersRepository()
    internal lazy var environmentRepository = EnvironmentRepository()
    
    public private(set) lazy var ext: [String : Any] = [:]
    public private(set) var isTestMode: Bool = false

    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @objc public static let sdkVersion = "0.1.2"
    
    @objc public static let defaultPlacement = "default"
    
    @objc public static let defaultMinPrice: Price = .unknown
    
    @objc public static var isInitialized: Bool { shared.isInitialized }
    
    private var isInitialized: Bool = false
    
    static let shared: BidonSdk = BidonSdk()
    
    private override init() {
        super.init()
    }
    
    @objc
    public static var logLevel: Logger.Level {
        get { Logger.level }
        set { Logger.level = newValue }
    }
    
    @objc
    public static var isTestMode: Bool {
        get { shared.isTestMode }
        set { shared.isTestMode = newValue }
    }
    
    @objc
    public static var baseURL: String {
        get { shared.networkManager.baseURL }
        set { shared.networkManager.baseURL = newValue }
    }
    
    @objc
    public static func registerDefaultAdapters() {
        shared.adaptersRepository.configure()
    }
    
    @objc
    public static func registerAdapter(className: String) {
        shared.adaptersRepository.register(className: className)
    }
    
    public static func registeredAdapters() -> [Adapter] {
        return shared.adaptersRepository.all()
    }
    
    public static func registerAdapter(adapter: Adapter) {
        shared.adaptersRepository.register(adapter: adapter)
    }
    
    @objc
    public static func initialize(
        appKey: String,
        completion: @escaping () -> () = {}
    ) {
        shared.initialize(
            appKey: appKey,
            completion: completion
        )
    }
    
    private func initialize(
        appKey: String,
        completion: (() -> ())?
    ) {
#warning("Incapsulate logic in tasks")
        environmentRepository.configure(
            EnvironmentRepository.Parameters(
                appKey: appKey,
                framework: .native
            )
        ) { [unowned self] in
            let request = ConfigurationRequest { builder in
                builder.withAdaptersRepository(self.adaptersRepository)
                builder.withEnvironmentRepository(self.environmentRepository)
                builder.withTestMode(self.isTestMode)
            }
            
            self.networkManager.perform(request: request) { result in
                switch result {
                case .success(let response):
                    let group = DispatchGroup()
                    response.adaptersInitializationParameters.adapters.forEach { [unowned self] parameters in
                        if let adapter: InitializableAdapter = self.adaptersRepository[parameters.key] {
                            group.enter()
                            let name = adapter.name
                            adapter.initialize(from: parameters.value) { result in
                                Logger.info("\(name) adapter initilized with result: \(result)")
                                group.leave()
                            }
                        }
                    }
                    group.notify(queue: .main) { [unowned self] in
                        self.isInitialized = true
                        completion?()
                    }
                case .failure(let error):
                    Logger.error("Network error while initilizing Bidon SDK: \(error)")
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
        }
    }
}