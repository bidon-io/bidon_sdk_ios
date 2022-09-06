//
//  Auctioncontroller.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 30.06.2022.
//

import Foundation


final class ConcurrentAuctionController<T, M>: AuctionController, MediationController
where T: DemandProvider, M: MediationObserver {
    
    typealias DemandType = DemandModel<T>
    typealias DemandProviderType = T
    typealias Observer = M
    
    private typealias RoundType = ConcurrentAuctionRound<DemandProviderType>
    private typealias AuctionType = Auction<RoundType>
    private typealias BidType = Bid<DemandProviderType>

    private let auction: AuctionType
    private let comparator: AuctionComparator
    private let adType: AdType
    private let pricefloor: Price
    
    let observer: Observer
        
    private lazy var active = Set<RoundType>()
    private lazy var repository = AdsRepository<DemandProviderType>()
    
    private var roundTimer: Timer?
    private var completion: Completion?
    
    var eventHandler: DemandEventHandler?
    
    private var currentPrice: Price {
        let current = repository
            .ads
            .sorted { comparator.compare($0, $1) }
            .first?
            .price
        return current ?? pricefloor
    }
    
    init<T>(_ build: (T) -> ()) where T: BaseConcurrentAuctionControllerBuilder<DemandProviderType, Observer> {
        let builder = T()
        build(builder)
        
        self.comparator = builder.comparator
        self.auction = builder.auction
        self.pricefloor = builder.pricefloor
        self.adType = builder.adType
        self.observer = builder.observer
    }
    
    func load(completion: @escaping Completion) {
        guard active.isEmpty else {
            completion(.failure(.internalInconsistency))
            return
        }
        
        self.completion = completion
        
        repository.clear()
        
        Logger.verbose("\(adType.rawValue.capitalized) auction will perform: \(auction)")
        
        eventHandler?(.didStartAuction)
        auction.root.forEach(perform)
    }
    
    private func provider<T>(for ad: Ad) -> T? {
        return repository.provider(for: ad) as? T
    }
    
    private func finish() {
        Logger.verbose("\(adType.rawValue.capitalized) auction did complete")
        
        active.forEach { $0.cancel() }
        active.removeAll()
        
        let ads = repository.ads.sorted { comparator.compare($0, $1) }
        
        defer { completion = nil }
        
        if let winner = ads.first {
            ads.suffix(ads.count - 1).forEach {
                let provider = repository.provider(for: $0)
                provider?.notify(.lose(winner))
            }
            
            let provider = repository.provider(for: winner)
            provider?.notify(.win(winner))
            
            Logger.verbose("\(adType.rawValue.capitalized) auction did found winner: \(winner)")
            
            completion?(.success(waterfall))
        } else {
            completion?(.failure(SdkError.internalInconsistency))
        }
    }
    
    private func perform(round: RoundType) {
        let pricefloor = currentPrice
        let adType = self.adType
        
        active.insert(round)
        eventHandler?(.didStartRound(round: round, pricefloor: pricefloor))
        
        if round.timeout.isNormal {
            let timer = Timer.scheduledTimer(
                withTimeInterval: Date.MeasurementUnits.milliseconds.convert(round.timeout, to: .milliseconds),
                repeats: false
            ) { _ in
                Logger.warning("\(adType.rawValue.capitalized) auction \(round) execution exceeded timeout.")
                round.cancel()
            }
            RunLoop.current.add(timer, forMode: .default)
            self.roundTimer = timer
        }
        
        Logger.verbose("Perform \(round)")
        round.perform(
            pricefloor: pricefloor,
            bid: { [weak self] result in
                switch result {
                case .success(let record):
                    self?.receive(record)
                case .failure(let error):
                    Logger.debug("\(adType.rawValue.capitalized) auction round: \(round) did receive error: \(error)")
                }
            },
            completion: { [weak self] in
                guard let self = self else { return }
                
                Logger.verbose("\(adType.rawValue.capitalized) auction complete round: \(round)")
                
                self.eventHandler?(.didCompleteRound(round: round))
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
    
    private func receive(_ record: BidType) {
        guard record.ad.price > pricefloor else {
            Logger.debug("\(adType.rawValue.capitalized) auction received bid: \(record.ad) price is lower than pricefloor: \(pricefloor)")
            return
        }
        
        Logger.verbose("\(adType.rawValue.capitalized) auction did receive bid: \(record.ad) from \(record.provider)")
        
        repository.register(record)
        
        #warning("Event")
//        delegate?.controller(
//            self,
//            didReceiveAd: record.ad,
//            provider: record.provider
//        )
    }
}


private extension ConcurrentAuctionController {
    var waterfall: WaterfallType {
        return WaterfallType(
            repository
                .ads
                .sorted { comparator.compare($0, $1) }
                .compactMap { repository.bid(for: $0) }
                .compactMap { ad, provider in
                    DemandType(
                        auctionId: observer.auctionId,
                        auctionConfigurationId: observer.auctionConfigurationId,
                        ad: ad,
                        provider: provider
                    )
                }
        )
    }
}
