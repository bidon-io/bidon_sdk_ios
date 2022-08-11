//
//  AppModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


struct AppModel: App, Codable {
    var bundle: String
    
    init(_ app: App) {
        self.bundle = app.bundle
    }
}
