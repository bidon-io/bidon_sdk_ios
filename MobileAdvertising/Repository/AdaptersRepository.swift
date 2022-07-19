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
    
    func register(_ adapter: Adapter) {
        self[adapter.identifier] = adapter
    }
}
