//
//  ALSdk+Extensions.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 28.06.2022.
//

import Foundation
import AppLovinSDK
import BidOn


extension MAError: Error {}


@objc public extension ALSdk {
    @objc(BNALSdkProxy)
    final class Proxy: NSObject {
        internal lazy var bidon = BidOnSdk()
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
        
        @objc public var adapters: [Adapter] { bidon.adapters }
        
        @objc public func register(adapter: Adapter) throws {
            try bidon.register(adapter: adapter)
        }
        
        @objc public func initializeSdk(completionHandler: ((ALSdkConfiguration) -> ())?) {
            Logger.level = applovin?.settings.isVerboseLogging == true ? .verbose : .error
            
            bidon.initialize { [weak self] in
                self?.applovin?.initializeSdk(completionHandler: completionHandler)
            }
        }
        
        internal func trackAdRevenue(
            _ ad: Ad,
            adType: BidOn.AdType,
            round: String
        ) {
            bidon.trackAdRevenue(
                ad,
                mediation: .applovin,
                auctionRound: round,
                adType: adType
            )
        }
    }

    
    @objc static let id: String = "applovin"
    
    private static var bidKey: UInt8 = 0
    
    @objc var bn: Proxy {
        if let proxy = objc_getAssociatedObject(self, &ALSdk.bidKey) as? Proxy {
            return proxy
        } else {
            let proxy = Proxy(sdk: self)
            objc_setAssociatedObject(self, &ALSdk.bidKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return proxy
        }
    }
}
