//
//  AdServiceBridge.swift
//  BidonAdapterAppLovin
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import Bidon
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


final class AppLovinAdServiceBridge: NSObject {
    private var response: DemandProviderResponse?
    private var lineItem: LineItem!
    
    func load(
        service: ALAdService,
        lineItem: LineItem,
        response: @escaping DemandProviderResponse
    ) {
        self.lineItem = lineItem
        self.response = response
        
        service.loadNextAd(
            forZoneIdentifier: lineItem.adUnitId,
            andNotify: self
        )
    }
}


extension AppLovinAdServiceBridge: ALAdLoadDelegate {
    func adService(_ adService: ALAdService, didLoad ad: ALAd) {
        response?(.success(ad))
        response = nil
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32) {
        let error = MediationError(alErrorCode: code)
        response?(.failure(error))
        response = nil
    }
}


private extension MediationError {
    init(alErrorCode: Int32) {
        switch alErrorCode {
        case kALErrorCodeNoFill: self = .noFill
        case kALErrorCodeSdkDisabled: self = .adapterNotInitialized
        case kALErrorCodeAdRequestNetworkTimeout: self = .networkError
        case kALErrorCodeNotConnectedToInternet: self = .networkError
        case kALErrorCodeInvalidZone: self = .incorrectAdUnitId
        default: self = .noBid
        }
    }
}
