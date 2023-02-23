//
//  Auctioncontroller.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 30.06.2022.
//

import Foundation


final class ConcurrentAuctionController<T, M>: AuctionController, MediationController
where M: MediationObserver, T == M.DemandProviderType {
    
    typealias DemandType = DemandModel<T>
    typealias DemandProviderType = T
    typealias Observer = M
    
    private typealias Event = MediationEvent<DemandProviderType>
    private typealias RoundType = ConcurrentAuctionRound<DemandProviderType>
    private typealias AuctionType = Auction<RoundType>
    private typealias RoundResultType = AuctionRoundBidResult<DemandProviderType>
    
    private let auction: AuctionType
    private let comparator: AuctionComparator
    private let pricefloor: Price
    
    let observer: Observer
    
    private lazy var active = Set<RoundType>()
    private lazy var repository = AdsRepository<DemandProviderType>()
    
    private var completion: Completion?
    
    private var currentECPM: Price {
        return currentWinner?.eCPM ?? pricefloor
    }
    
    private var currentWinner: Ad? {
        return repository
            .ads
            .sorted { comparator.compare($0, $1) }
            .first
    }
    
    init<T>(_ build: (T) -> ()) where T: BaseConcurrentAuctionControllerBuilder<DemandProviderType, Observer> {
        let builder = T()
        build(builder)
        
        self.comparator = builder.comparator
        self.auction = builder.auction
        self.pricefloor = builder.pricefloor
        self.observer = builder.observer
    }
    
    func load(completion: @escaping Completion) {
        guard active.isEmpty else {
            completion(.failure(.internalInconsistency))
            return
        }
        
        self.completion = completion
        
        repository.clear()
        
        observer.log(.auctionStart)
        auction.root.forEach(perform)
    }
    
    private func provider<T>(for ad: Ad) -> T? {
        return repository.provider(for: ad) as? T
    }
    
    private func finish() {
        active.forEach { $0.cancel() }
        active.removeAll()
        
        defer { completion = nil }
        
        if let winner = currentWinner {
            repository.ads.forEach { ad in
                let provider = repository.provider(for: ad)
                let event: AuctionEvent = ad.id == winner.id ? .win : .lose(winner)
                provider?.notify(ad: ad, event: event)
            }
            
            let event = Event.auctionFinish(winner: winner)
            observer.log(event)
            completion?(.success(waterfall))
        } else {
            let event = Event.auctionFinish(winner: nil)
            observer.log(event)
            
            completion?(.failure(SdkError.internalInconsistency))
        }
    }
    
    private func perform(round: RoundType) {
        let pricefloor = currentECPM
        
        active.insert(round)
        
        let event = Event.roundStart(
            round: round,
            pricefloor: pricefloor
        )
        
        observer.log(event)
        
        round.onDemandRequest = { [unowned round, unowned self] adapter, lineItem in
            self.round(round, didRequestDemand: adapter, lineItem: lineItem)
        }
        
        round.onDemandResponse = { [unowned round, unowned self] adapter, result in
            switch result {
            case .success(let bid):
                self.round(round, didReceive: bid, adapter: adapter)
            case .failure(let error):
                self.round(round, didReceive: error, adapter: adapter)
            }
        }
        
        round.onRoundComplete = { [unowned round, unowned self] in
            self.complete(round: round)
        }
        
        round.perform(pricefloor: pricefloor)
    }
    
    private func round(
        _ round: RoundType,
        didRequestDemand adapter: Adapter,
        lineItem: LineItem?
    ) {
        let event = Event.bidRequest(
            round: round,
            adapter: adapter,
            lineItem: lineItem
        )
        
        observer.log(event)
    }
    
    private func round(
        _ round: RoundType,
        didReceive bid: Bid<DemandProviderType>,
        adapter: Adapter
    ) {
        guard bid.ad.eCPM > pricefloor else {
            let event = Event.bidError(
                round: round,
                adapter: adapter,
                error: .belowPricefloor
            )
            observer.log(event)
            return
        }
        
        let event = Event.bidResponse(
            round: round,
            adapter: adapter,
            bid: bid
        )
        
        observer.log(event)
        repository.register(bid)
    }
    
    private func round(
        _ round: RoundType,
        didReceive error: MediationError,
        adapter: Adapter
    ) {
        let event = Event.bidError(
            round: round,
            adapter: adapter,
            error: error
        )
        observer.log(event)
    }
}


private extension ConcurrentAuctionController {
    
    
    func auctionRound(_ auctionRound: AuctionRound, didReceiveBid bid: Bid<T>) {
        
    }

    private func receive(
        round: AuctionRound,
        request adapter: Adapter,
        lineItem: LineItem?
    ) {
        let event = Event.bidRequest(
            round: round,
            adapter: adapter,
            lineItem: lineItem
        )
        
        observer.log(event)
    }
    
    private func complete(round: RoundType) {
        let event = Event.roundFinish(
            round: round,
            winner: currentWinner
        )
        observer.log(event)
        
        active.remove(round)
        
        let seeds = auction.seeds(of: round)
        if seeds.isEmpty && active.isEmpty {
            finish()
        } else {
            seeds.forEach(perform)
        }
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
