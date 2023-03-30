//
//  Auctioncontroller.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 30.06.2022.
//

import Foundation


final class ConcurrentAuctionController<DemandProviderType: DemandProvider>: AuctionController {
    typealias BidType = BidModel<DemandProviderType>
    
    private typealias RoundType = ConcurrentAuctionRound<DemandProviderType>
    private typealias AuctionType = Auction<RoundType>
    
    private let auction: AuctionType
    private let comparator: AuctionComparator
    private let pricefloor: Price
    
    let mediationObserver: AnyMediationObserver
    let adRevenueObserver: AdRevenueObserver
    
    private lazy var active = Set<RoundType>()
    private lazy var repository = BidRepository<BidType>()
    
    private var completion: Completion?
        
    private var currentECPM: Price {
        return currentWinner?.eCPM ?? pricefloor
    }
    
    private var currentWinner: BidType? {
        return repository
            .all
            .sorted { comparator.compare($0, $1) }
            .first
    }
    
    init<T>(_ build: (T) -> ()) where T: BaseConcurrentAuctionControllerBuilder<DemandProviderType> {
        let builder = T()
        build(builder)
        
        self.comparator = builder.comparator
        self.auction = builder.auction
        self.pricefloor = builder.pricefloor
        self.mediationObserver = builder.mediationObserver
        self.adRevenueObserver = builder.adRevenueObserver
    }
    
    func load(completion: @escaping Completion) {
        guard active.isEmpty else {
            completion(.failure(.internalInconsistency))
            return
        }
        
        self.completion = completion
        
        repository.clear()
        
        mediationObserver.log(.auctionStart)
        auction.root.forEach(perform)
    }
    
    private func provider(for ad: DemandAd) -> DemandProviderType? {
        return repository.bid(for: ad)?.provider
    }
    
    private func finish() {
        active.forEach { $0.cancel() }
        active.removeAll()
        
        defer { completion = nil }
        
        if let winner = currentWinner {
            repository.ads.forEach { ad in
                let provider = provider(for: ad)
                let event: AuctionEvent = ad.id == winner.ad.id ? .win : .lose(winner.ad, winner.eCPM)
                provider?.notify(opaque: ad, event: event)
            }
            
            let event = MediationEvent.auctionFinish(winner: winner)
            mediationObserver.log(event)
            completion?(.success(waterfall))
        } else {
            let event = MediationEvent.auctionFinish(winner: nil)
            mediationObserver.log(event)
            
            completion?(.failure(SdkError.internalInconsistency))
        }
    }
    
    private func perform(round: RoundType) {
        let pricefloor = currentECPM
        
        active.insert(round)
        
        let event = MediationEvent.roundStart(
            round: round,
            pricefloor: pricefloor
        )
        
        mediationObserver.log(event)
        
        round.onDemandRequest = { [unowned round, unowned self] adapter, lineItem in
            self.round(round, didRequestDemand: adapter, lineItem: lineItem)
        }
        
        round.onDemandResponse = { [unowned round, unowned self] adapter, result in
            switch result {
            case .success((let provider, let ad, let lineItem)):
                self.round(
                    round,
                    didReceive: ad,
                    provider: provider,
                    lineItem: lineItem,
                    adapter: adapter
                )
            case .failure(let error):
                self.round(
                    round,
                    didReceive: error,
                    adapter: adapter
                )
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
        let event = MediationEvent.bidRequest(
            round: round,
            adapter: adapter,
            lineItem: lineItem
        )
        
        mediationObserver.log(event)
    }
    
    private func round(
        _ round: RoundType,
        didReceive ad: DemandAd,
        provider: DemandProviderType,
        lineItem: LineItem?,
        adapter: Adapter
    ) {
        let bid = BidType(
            auctionId: mediationObserver.auctionId,
            auctionConfigurationId: mediationObserver.auctionConfigurationId,
            roundId: round.id,
            adType: mediationObserver.adType,
            lineItem: lineItem,
            ad: ad,
            provider: provider
        )
        
        guard bid.eCPM > pricefloor else {
            let event = MediationEvent.bidError(
                round: round,
                adapter: adapter,
                error: .belowPricefloor
            )
            mediationObserver.log(event)
            return
        }
        
        adRevenueObserver.observe(bid)
        let event = MediationEvent.bidResponse(
            round: round,
            adapter: adapter,
            bid: bid
        )
        mediationObserver.log(event)
        
        repository.register(bid)
    }
    
    private func round(
        _ round: RoundType,
        didReceive error: MediationError,
        adapter: Adapter
    ) {
        let event = MediationEvent.bidError(
            round: round,
            adapter: adapter,
            error: error
        )
        mediationObserver.log(event)
    }
    
    private func complete(round: RoundType) {
        let event = MediationEvent.roundFinish(
            round: round,
            winner: currentWinner
        )
        mediationObserver.log(event)
        
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
                .all
                .sorted { comparator.compare($0, $1) }
        )
    }
}
