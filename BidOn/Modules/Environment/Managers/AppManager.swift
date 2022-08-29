//
//  AppManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation



final class AppManager: App {
    let key: String
    let bundle: String = Bundle.main.bundleIdentifier ?? ""
    
    init(key: String) {
        self.key = key
    }
}
