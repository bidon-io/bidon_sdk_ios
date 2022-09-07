//
//  AnyAdapter.swift
//  BidOn
//
//  Created by Stas Kochkin on 07.09.2022.
//

import Foundation


struct AnyAdapter: Adapter, Hashable {
    var identifier: String
    var name: String
    var adapterVersion: String
    var sdkVersion: String
    
    init(adapter: Adapter) {
        self.identifier = adapter.identifier
        self.name = adapter.name
        self.adapterVersion = adapter.adapterVersion
        self.sdkVersion = adapter.sdkVersion
    }
    
    init(demand: String) {
        self.identifier = demand
        self.name = "Unknown"
        self.adapterVersion = ""
        self.sdkVersion = ""
    }
    
    init() {
        fatalError("Any Adapter can not be created through default initializer")
    }
}


extension AnyAdapter: CustomStringConvertible {
    var description: String {
        return "\(name) ('\(identifier)')"
    }
}

