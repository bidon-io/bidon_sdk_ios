//
//  AdServiceBridge.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import BidOn
import AppLovinSDK


fileprivate struct AdServiceBridgeInjectionKey: InjectionKey {
    static var currentValue: AdServiceBridge = AdServiceBridge()
}


extension InjectedValues {
    var bridge: AdServiceBridge {
        get { Self[AdServiceBridgeInjectionKey.self] }
        set { Self[AdServiceBridgeInjectionKey.self] = newValue }
    }
}


final class AdServiceBridge {
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
            let wrapped = ALAdWrapper(ad, price: lineItem.pricefloor)
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
