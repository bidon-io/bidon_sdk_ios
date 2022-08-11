//
//  AuctionContoller.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 30.06.2022.
//

import Foundation


internal typealias ConcurrentAuction = Auction<ConcurrentAuctionRound>


final class ConcurrentAuctionController: AuctionController {
    private let auction: ConcurrentAuction
    private let resolver: AuctionResolver
    private let adType: AdType
    private let pricefloor: Price
    
    private weak var delegate: AuctionControllerDelegate?
    
    private lazy var active = Set<ConcurrentAuctionRound>()
    private lazy var repository = AdsRepository()
    
    private var roundTimer: Timer?
    
    private(set) public var winner: Ad?
    
    init<T>(_ build: (T) -> ()) where T: ConcurrentAuctionControllerBuilder {
        let builder = T()
        build(builder)
    
        self.resolver = builder.resolver
        self.auction = builder.auction
        self.pricefloor = builder.pricefloor
        self.adType = builder.adType
    }
    
    public var isEmpty: Bool {
        return repository.isEmpty
    }
    
    public func load() {
        guard active.isEmpty else { return }
        
        winner = nil
        repository.clear()
        
        Logger.verbose("Auction controller will perform \(adType.rawValue) auction: \(auction)")
        
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
        
        Logger.verbose("Complete auction")
        
        let ads = repository.ads
        active.forEach { $0.cancel() }
        active.removeAll()
        resolver.resolve(ads: ads) { [weak self] ad in
            guard let self = self else { return }
            guard let ad = ad else {
                self.delegate?.controller(self, failedAuction: SdkError.internalInconsistency)
                completion?(nil, nil, SdkError.internalInconsistency)
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
            
            Logger.verbose("Auction controller did resolve winner of \(self.adType.rawValue) auction is \(ad.description)")
            
            self.winner = ad
            self.delegate?.controller(self, completeAuction: ad)
            
            completion?(provider, ad, nil)
        }
    }
    
    func perform(round: ConcurrentAuctionRound) {
        let pricefloor = repository.pricefloor
        let adType = self.adType
        
        active.insert(round)
        delegate?.controller(self, didStartRound: round, pricefloor: pricefloor)
        
        if round.timeout.isNormal {
            let timer = Timer.scheduledTimer(withTimeInterval: round.timeout, repeats: false) { _ in
                Logger.warning("Auction controller \(adType.rawValue) \(round) execution exceeded timeout.")
                round.cancel()
            }
            RunLoop.current.add(timer, forMode: .default)
            self.roundTimer = timer
        }
        
        Logger.verbose("Perform \(round)")
        round.perform(
            pricefloor: pricefloor,
            demand: { [weak self] result in
                switch result {
                case .success(let demand):
                    self?.receive(demand: demand)
                case .failure(let error):
                    Logger.debug("Error during round: \(error)")
                }
            },
            completion: { [weak self] in
                guard let self = self else { return }
                
                Logger.verbose("Complete \(round)")

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
    
    func receive(demand: Demand) {
        Logger.verbose("Auction controller did receive \(adType.rawValue) ad: \(demand.ad.description) from \(demand.provider)")
        
        repository.register(demand: demand)
        
        delegate?.controller(
            self,
            didReceiveAd: demand.ad,
            provider: demand.provider
        )
    }
}
