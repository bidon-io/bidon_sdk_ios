//
//  App.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation

#warning("Fill in all required fields")
protocol App: Environment {
    var bundle: String { get }
}


struct CodableApp: App, Codable {
    var bundle: String
    
    init(_ app: App) {
        self.bundle = app.bundle
    }
}
