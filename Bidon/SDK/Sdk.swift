//
//  SDK.swift
//  Bidon
//
//  Created by Bidon Team on 11.08.2022.
//

import Foundation


fileprivate struct SdkInjectionKey: InjectionKey {
    static var currentValue: Sdk = BidonSdk.shared
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
}


extension BidonSdk: Sdk {}
