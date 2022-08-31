//
//  SDK.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


fileprivate struct SdkInjectionKey: InjectionKey {
    static var currentValue: Sdk = BidOnSdk.sharedSdk
}


extension InjectedValues {
    var sdk: Sdk {
        get { Self[SdkInjectionKey.self] }
        set { Self[SdkInjectionKey.self] = newValue }
    }
}


protocol Sdk {
    var adaptersRepository: AdaptersRepository { get }
    var environmentRepository: EnvironmentRepository { get }
    var ext: [String: Any] { get }
    
    func trackAdRevenue(
        _ ad: Ad,
        adType: AdType
    )
}


extension BidOnSdk: Sdk {}
