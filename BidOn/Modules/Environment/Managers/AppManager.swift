//
//  AppManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation


final class AppManager: App, EnvironmentManager {
    let bundle: String = Bundle.main.bundleIdentifier ?? ""
    let version: String = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    let key: String
    let framework: String
    let frameworkVersion: String?
    let pluginVersion: String?
    
    init(
        key: String,
        framework: Framework,
        frameworkVersion: String?,
        pluginVersion: String?
    ) {
        self.key = key
        self.framework = framework.description
        self.frameworkVersion = frameworkVersion
        self.pluginVersion = pluginVersion
    }
}


extension Framework: CustomStringConvertible {
    public var description: String {
        switch self {
        case .native: return "native"
        case .unity: return "unity"
        case .flutter: return "flutter"
        case .reactNative: return "react-native"
        }
    }
}
