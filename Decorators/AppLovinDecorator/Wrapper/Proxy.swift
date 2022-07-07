//
//  ALSdk+Extensions.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 28.06.2022.
//

import Foundation
import AppLovinSDK
import MobileAdvertising


extension MAError: Error {}


@objc public final class Proxy: NSObject {
    internal lazy var bidon = SDK()
    fileprivate weak var applovin: ALSdk?
    
    fileprivate init(sdk: ALSdk?) {
        self.applovin = sdk
        super.init()
    }
    
    public func register<T: ParameterizedAdapter>(
        adapter: T.Type,
        parameters: T.Parameters
    ) {
        bidon.register(
            adapter: adapter,
            parameters: parameters
        )
    }
    
    @objc public func register(adapter: Adapter) throws {
        try bidon.register(adapter: adapter)
    }
    
    @objc public func initializeSdk(completionHandler: ((ALSdkConfiguration) -> ())?) {
        bidon.initialize { [weak self] in
            self?.applovin?.initializeSdk(completionHandler: completionHandler)
        }
    }
}


@objc public extension ALSdk {
    @objc static let id: String = "applovin"
    
    private static var bidKey: UInt8 = 0
    
    @objc var bid: Proxy {
        if let proxy = objc_getAssociatedObject(self, &ALSdk.bidKey) as? Proxy {
            return proxy
        } else {
            let proxy = Proxy(sdk: self)
            objc_setAssociatedObject(self, &ALSdk.bidKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return proxy
        }
    }
}
