//
//  AdaptersRepository.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


internal typealias AdaptersRepository = Repository<String, Adapter>


extension AdaptersRepository {
    convenience init() {
        self.init("com.ads.adapters-repository.queue")
    }
    
    var ids: [String] {
        return Array(keys)
    }
    
    func register(className: String) {
        if let cls = NSClassFromString(className) as? Adapter.Type {
            let adapter = cls.init()
            Logger.debug("Register \(adapter.name) adapter. Version \(BidOnSdk.sdkVersion).\(adapter.adapterVersion). SDK Version: \(adapter.sdkVersion)")
            self[adapter.identifier] = adapter
        } else {
            Logger.error("Adapter with class: \(className) wasn't found")
        }
    }
    
    func register(adapter: Adapter) {
        Logger.debug("Register \(adapter.name) adapter. Version \(BidOnSdk.sdkVersion).\(adapter.adapterVersion). SDK Version: \(adapter.sdkVersion)")
        self[adapter.identifier] = adapter
    }
    
    func configure() {
        Constants.Adapters.clasess.forEach { className in
            if let cls = NSClassFromString(className) as? Adapter.Type {
                let adapter = cls.init()
                Logger.debug("Register \(adapter.name) adapter. Version \(BidOnSdk.sdkVersion).\(adapter.adapterVersion). SDK Version: \(adapter.sdkVersion)")
                self[adapter.identifier] = adapter
            }
        }
    }
}

