//
//  AdsRepository.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 04.07.2022.
//

import Foundation


final class BidRepository<BidType: Bid> {
    internal let queue = DispatchQueue(
        label: "com.bidon.bid-repository.queue",
        attributes: .concurrent
    )
    
    private var bids = Set<BidType>()
    
    var all: [BidType] {
        return queue.sync { [unowned self] in
            return Array(self.bids)
        }
    }
    
    var ads: [DemandAd] {
        return queue.sync { [unowned self] in
            self.bids.map { $0.ad }
        }
    }
    
    func register(_ bid: BidType) {
        queue.async(flags: .barrier) { [unowned self] in
            self.bids.insert(bid)
        }
    }
    
    func bid(for ad: DemandAd) -> BidType? {
        return queue.sync { [unowned self] in
            return self.bids.first { $0.ad.id == ad.id }
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) { [unowned self] in
            self.bids.removeAll()
        }
    }
}
