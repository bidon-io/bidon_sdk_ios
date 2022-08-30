//
//  AdsRepository.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


internal typealias AdsRepository = Repository<HashableAd, DemandProvider>

typealias AdRecord = (ad: Ad, provider: DemandProvider)

extension AdsRepository {
    convenience init() {
        self.init("com.ads.ads-repository.queue")
    }
    
    var ads: [Ad] {
        return objects.keys.map { $0.ad }
    }
    
    func register(_ record: AdRecord) {
        let container = HashableAd(ad: record.ad)
        self[container] = record.provider
    }
    
    func provider(for ad: Ad) -> DemandProvider? {
        return record(for: ad)?.1
    }
    
    func record(for ad: Ad) -> AdRecord? {
        let container = HashableAd(ad: ad)
        let provider: DemandProvider? = self[container]
        
        return provider.map { (ad, $0) }
    }
}
