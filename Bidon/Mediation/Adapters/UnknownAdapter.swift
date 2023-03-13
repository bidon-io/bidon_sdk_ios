//
//  UnknownAdapter.swift
//  Bidon
//
//  Created by Stas Kochkin on 13.03.2023.
//

import Foundation


struct UnknownAdapter: Adapter, Hashable {
    var identifier: String
    var name: String
    var adapterVersion: String
    var sdkVersion: String
    
    init(identifier: String) {
        self.identifier = identifier
        self.name = "Unknown"
        self.adapterVersion = ""
        self.sdkVersion = ""
    }
    
    init() {
        fatalError("UnknownAdapter can't be created through default initializer")
    }
}
