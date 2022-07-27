//
//  AppsFlyerParameters.swift
//  AppsFlyerAdapter
//
//  Created by Stas Kochkin on 19.07.2022.
//

import Foundation
import BidOn


public struct AppsFlyerParameters: Codable {
    var devKey: String
    var appId: String
    
    public init(
        devKey: String,
        appId: String
    ) {
        self.devKey = devKey
        self.appId = appId
    }
}
