//
//  AdsRepository.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation


internal struct Demand {
    var provider: DemandProvider
    var round: AuctionRound
}

internal typealias AdsRepository = Repository<HashableAd, Demand>


extension AdsRepository {
    convenience init() {
        self.init("com.ads.ads-repository.queue")
    }
    
    var pricefloor: Price {
        objects.keys.reduce(Price.unknown) { max($0, $1.ad.price) }
    }
    
    var ads: [Ad] {
        return objects.keys.map { $0.ad }
    }
    
    func register(ad: Ad, provider: DemandProvider, round: AuctionRound) {
        let container = HashableAd(ad: ad)
        self[container] = Demand(
            provider: provider,
            round: round
        )
    }
    
    func provider(for ad: Ad) -> DemandProvider? {
        let container = HashableAd(ad: ad)
        
        return queue.sync { [unowned self] in
            return (self.objects[container] as? Demand)?.provider
        }
    }
    
    func round(for ad: Ad) -> AuctionRound? {
        let container = HashableAd(ad: ad)
        
        return queue.sync { [unowned self] in
            return (self.objects[container] as? Demand)?.round
        }
    }
}
