//
//  AdsRepository.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


internal typealias AdsRepository = Repository<HashableAd, DemandProvider>


extension AdsRepository {
    convenience init() {
        self.init("com.ads.ads-repository.queue")
    }
    
    var ads: [Ad] {
        return objects.keys.map { $0.ad }
    }
    
    func register(demand: Demand) {
        let container = HashableAd(ad: demand.ad)
        self[container] = demand.provider
    }
    
    func provider(for ad: Ad) -> DemandProvider? {
        return demand(for: ad)?.provider
    }
    
    func demand(for ad: Ad) -> Demand? {
        let container = HashableAd(ad: ad)
        let provider: DemandProvider? = self[container]
        
        return provider.map { (ad, $0) }
    }
}
