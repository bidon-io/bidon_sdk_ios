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
        queue.sync { [unowned self] in
            return Array(self.objects.keys)
        }
    }
    
    func configure() {
        Constants.Adapters.clasess.forEach { className in
            if let cls = NSClassFromString(className) as? Adapter.Type {
                let adapter = cls.init()
                Logger.debug("Register \(adapter.name) adapter. Version \(BidOnSdk.sdkVersion).\(adapter.version). SDK Version: \(adapter.sdkVersion)")
                self[adapter.identifier] = adapter
            }
        }
    }
}

