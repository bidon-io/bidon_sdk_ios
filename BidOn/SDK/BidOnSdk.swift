//
//  SDK.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 15.06.2022.
//

import Foundation
import UIKit


@objc
public final class BidOnSdk: NSObject {
    internal lazy var adaptersRepository = AdaptersRepository()
    internal lazy var environmentRepository = EnvironmentRepository()
    internal lazy var ext: [String : Any] = [:]
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @objc public static let sdkVersion = "0.1.0"
    
    static let sharedSdk: BidOnSdk = BidOnSdk()
    
    private override init() {
        super.init()
    }
    
    @objc
    public static var logLevel: Logger.Level {
        get { Logger.level }
        set { Logger.level = newValue }
    }
    
    @objc
    public static var baseURL: String {
        get { sharedSdk.networkManager.baseURL }
        set { sharedSdk.networkManager.baseURL = newValue }
    }
    
    @objc
    public static func initialize(
        appKey: String,
        completion: @escaping () -> () = {}
    ) {
        sharedSdk.initialize(
            appKey: appKey,
            completion: completion
        )
    }
    
    private func initialize(
        appKey: String,
        completion: @escaping () -> ()
    ) {
        
#warning("Incapsulate logic in tasks")
        
        adaptersRepository.configure()
        
        environmentRepository.configure(
            EnvironmentRepository.Parameters(
                appKey: appKey,
                framework: .native
            )
        ) { [unowned self] in
            let request = ConfigurationRequest { builder in
                builder.withAdaptersRepository(self.adaptersRepository)
                builder.withEnvironmentRepository(self.environmentRepository)
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
                    group.notify(queue: .main, execute: completion)
                case .failure(let error):
                    Logger.error("Network error while initilizing BidOn SDK: \(error)")
                    DispatchQueue.main.async(execute: completion)
                }
            }
        }
    }
    
    func trackAdRevenue(
        _ ad: Ad,
        adType: AdType
    ) {
        let mmps: [MobileMeasurementPartnerAdapter] = adaptersRepository.all()
        mmps.forEach {
            Logger.verbose("MMP '\($0.identifier)' tracks \(adType.rawValue) ad revenue: \(ad)")
            
            $0.trackAdRevenue(
                ad,
                adType: adType
            )
        }
    }
}
