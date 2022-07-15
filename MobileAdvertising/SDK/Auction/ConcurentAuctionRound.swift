//
//  ConcurentAuctionRound.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation


struct ConcurentAuctionRound: PerformableAuctionRound {
    var id: String
    var timeout: TimeInterval
    var providers: [DemandProvider]
    
    private var group = DispatchGroup()
    private var completion: (() -> ())?
    private var isCancelled: Bool = false
    
    init(
        id: String,
        timeout: TimeInterval,
        providers: [DemandProvider]
    ) {
        self.id = id
        self.timeout = timeout
        self.providers = providers
    }
    
    func perform(
        pricefloor: Price,
        demand: @escaping AuctionRoundDemand,
        completion: @escaping AuctionRoundCompletion
    ) {
        providers.forEach { provider in
            group.enter()
            provider.request(pricefloor: pricefloor) { [weak provider] ad, error in
                defer { group.leave() }
                guard let provider = provider, let ad = ad
                else { return }
                demand(ad, provider)
            }
        }
                
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func cancel() {
        providers.forEach { $0.cancel() }
    }
}


extension ConcurentAuctionRound {
    static func == (lhs: ConcurentAuctionRound, rhs: ConcurentAuctionRound) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
