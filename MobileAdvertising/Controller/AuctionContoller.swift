//
//  AuctionContoller.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 30.06.2022.
//

import Foundation


internal typealias ConcurentAuction = Auction<ConcurentAuctionRound>

public final class AuctionController {
    private let auction: ConcurentAuction
    private let resolver: AuctionResolver
    
    private weak var delegate: AuctionControllerDelegate?
    
    private lazy var active = Set<ConcurentAuctionRound>()
    private lazy var repository = AdsRepository()
    
    private var roundTimer: Timer?
    
    private(set) public var winner: Ad?
    
    internal init(
        auction: ConcurentAuction,
        resover: AuctionResolver,
        delegate: AuctionControllerDelegate?
    ) {
        self.delegate = delegate
        self.auction = auction
        self.resolver = resover
    }
    
    public var isEmpty: Bool {
        return repository.isEmpty
    }
    
    public func load() {
        guard active.isEmpty else { return }
        
        winner = nil
        repository.clear()
        
        delegate?.controllerDidStartAuction(self)
        auction.root.forEach(perform)
    }
    
    public func provider<T>(for ad: Ad) -> T? {
        return repository.provider(for: ad) as? T
    }
    
    public func finish(
        completion: ((DemandProvider?, Ad?, Error?) -> ())? = nil
    ) {
        if let winner = winner {
            let provider = repository.provider(for: winner)
            completion?(provider, winner, nil)
            return
        }
        
        let ads = repository.ads
        active.forEach { $0.cancel() }
        active.removeAll()
        resolver.resolve(ads: ads) { [weak self] ad in
            guard let self = self else { return }
            guard let ad = ad else {
                self.delegate?.controller(self, failedAuction: SDKError.internalInconsistency)
                completion?(nil, nil, SDKError.internalInconsistency)
                return
            }
            
            var provider: DemandProvider?
            
            ads.forEach { _ad in
                let _provider = self.repository.provider(for: _ad)
                
                if _ad.id == ad.id {
                    _provider?.notify(.win(ad))
                    provider = _provider
                } else {
                    _provider?.notify(.lose(ad))
                }
            }
            
            self.winner = ad
            self.delegate?.controller(self, completeAuction: ad)
            
            completion?(provider, ad, nil)
        }
    }
    
    public func auctionRound(for ad: Ad) -> AuctionRound? {
        return repository.round(for: ad)
    }
    
    func perform(round: ConcurentAuctionRound) {
        let pricefloor = repository.pricefloor
        
        active.insert(round)
        delegate?.controller(self, didStartRound: round, pricefloor: pricefloor)
        
        if round.timeout.isNormal {
            let timer = Timer.scheduledTimer(withTimeInterval: round.timeout, repeats: false) { _ in
                round.cancel()
            }
            RunLoop.current.add(timer, forMode: .default)
            self.roundTimer = timer
        }
        
        round.perform(
            pricefloor: pricefloor,
            demand: { [weak self] ad, provider in
                self?.receive(demand: ad, provider: provider, round: round)
            },
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.controller(self, didCompleteRound: round)
                self.active.remove(round)
                self.roundTimer?.invalidate()
                
                let seeds = self.auction.seeds(of: round)
                if seeds.isEmpty && self.active.isEmpty {
                    self.finish()
                } else {
                    seeds.forEach(self.perform)
                }
            }
        )
    }
    
    func receive(
        demand: Ad,
        provider: DemandProvider,
        round: AuctionRound
    ) {
        repository.register(
            ad: demand,
            provider: provider,
            round: round
        )
        
        delegate?.controller(
            self,
            didReceiveAd: demand,
            provider: provider
        )
    }
}
