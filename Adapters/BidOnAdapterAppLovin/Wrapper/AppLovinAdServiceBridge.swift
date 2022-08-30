//
//  AdServiceBridge.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import BidOn
import AppLovinSDK


fileprivate struct AppLovinAdServiceBridgeInjectionKey: InjectionKey {
    static var currentValue: AppLovinAdServiceBridge = AppLovinAdServiceBridge()
}


extension InjectedValues {
    var bridge: AppLovinAdServiceBridge {
        get { Self[AppLovinAdServiceBridgeInjectionKey.self] }
        set { Self[AppLovinAdServiceBridgeInjectionKey.self] = newValue }
    }
}


final class AppLovinAdServiceBridge {
    final private class Delegate: NSObject, ALAdLoadDelegate {
        private let response: DemandProviderResponse
        private let lineItem: LineItem
        
        init(
            lineItem: LineItem,
            response: @escaping DemandProviderResponse
        ) {
            self.response = response
            self.lineItem = lineItem
            
            super.init()
        }
        
        func adService(_ adService: ALAdService, didLoad ad: ALAd) {
            let wrapped = AppLovinAd(lineItem, ad)
            response(.success(wrapped))
        }
        
        func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
            response(.failure(SdkError.noFill))
        }
    }
        
    func load(
        _ service: ALAdService,
        lineItem: LineItem,
        completion: @escaping DemandProviderResponse
    ) {
        let delegate = Delegate(
            lineItem: lineItem,
            response: completion
        )
        
        service.loadNextAd(
            forZoneIdentifier: lineItem.adUnitId,
            andNotify: delegate
        )
    }
}
