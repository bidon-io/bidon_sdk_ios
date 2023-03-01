//
//  AdsRepository.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 04.07.2022.
//

import Foundation


internal typealias AdsRepository<DemandProviderType: DemandProvider> = Repository<HashableAd, DemandProviderType>

typealias Bid<DemandProviderType: DemandProvider> = (ad: Ad, provider: DemandProviderType)


internal struct HashableAd: Hashable  {
    var ad: Ad
    
    init(ad: Ad) {
        self.ad = ad
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ad.id)
    }
    
    static func == (lhs: HashableAd, rhs: HashableAd) -> Bool {
        return lhs.ad.id == rhs.ad.id
    }
}


extension Repository where Key == HashableAd, Value: DemandProvider  {
    convenience init() {
        self.init("com.ads.ads-repository.queue")
    }
    
    var ads: [Ad] {
        return keys.map { $0.ad }
    }
    
    func register(_ bid: Bid<Value>) {
        let container = HashableAd(ad: bid.ad)
        self[container] = bid.provider
    }
    
    func provider(for ad: Ad) -> Value? {
        return bid(for: ad)?.1
    }
    
    func bid(for ad: Ad) -> Bid<Value>? {
        let container = HashableAd(ad: ad)
        let provider: Value? = self[container]
        
        return provider.map { (ad, $0) }
    }
}
