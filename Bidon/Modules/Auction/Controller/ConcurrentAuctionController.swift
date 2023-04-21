//
//  Auctioncontroller.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 30.06.2022.
//

import Foundation


final class ConcurrentAuctionController<DemandProviderType: DemandProvider>: AuctionController {
    typealias BidType = BidModel<DemandProviderType>
    
//    private typealias RoundType = ConcurrentAuctionRound<DemandProviderType>
//    private typealias AuctionType = Auction<RoundType>
    
    private let rounds: [AuctionRound]
    private let adapters: [AnyDemandSourceAdapter<DemandProviderType>]
    private let comparator: AuctionBidComparator
    private let pricefloor: Price
    
    private let mediationObserver: AnyMediationObserver
    private let adRevenueObserver: AdRevenueObserver

    private var completion: Completion?
    private var elector: AuctionLineItemElector
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.bidon.auction.queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        queue.isSuspended = true
        return queue
    }()
    
//    private let bids = ThreadSafeBidSet<BidType>()
//    private var active = Set<RoundType>()
    
    init<T>(_ build: (T) -> ()) where T: BaseConcurrentAuctionControllerBuilder<DemandProviderType> {
        let builder = T()
        build(builder)
        
        self.elector = builder.elector
        self.comparator = builder.comparator
        self.rounds = builder.rounds
        self.adapters = builder.adapters()
        self.pricefloor = builder.pricefloor
        self.mediationObserver = builder.mediationObserver
        self.adRevenueObserver = builder.adRevenueObserver
    }
    
    func load(
        completion: @escaping Completion
    ) {
        guard queue.isSuspended else {
            completion(.failure(.internalInconsistency))
            return
        }
        
        let start = ConcurrentAuctionStartOperation(
            pricefloor: pricefloor,
            observer: mediationObserver
        )
        
        let rounds = rounds.map { round in
            let start = ConcurrentAuctionStartRoundOperation<BidType>(
                observer: mediationObserver,
                round: round
            )
            
//            round.demands.map { id in
//                let adapter = adapters.first { $0.identifier == id } ?? UnknownAdapter(identifier: id)
//                let request = ConcurrentAuctionRequestDemandOperation<DemandProviderType>(
//                    round: round,
//                    observer: mediationObserver,
//                    adapter: adapter
//                ) { [weak self] adapter, pricefloor in
//                    self?.elector.popLineItem(
//                        for: adapter.identifier,
//                        pricefloor: pricefloor
//                    )
//                }
//
//            }
            
        }
//        let startAuction = StartAuctionOperation(observer: mediationObserver)
//        guard active.isEmpty else {
//            completion(.failure(.internalInconsistency))
//            return
//        }
//
//        self.completion = completion
//
//        bids.removeAll()
//
//        mediationObserver.log(.auctionStart)
//        auction.root.forEach(perform)
    }
    
//    private func provider(for ad: DemandAd) -> DemandProviderType? {
//        return bids.bid(for: ad)?.provider
//    }
    
//    private func finish() {
//        active.forEach { $0.cancel() }
//        active.removeAll()
//
//        defer { completion = nil }
//
////        let waterfall = waterfall
////        let event = MediationEvent.auctionFinish(
////            waterfall: waterfall
////        )
////        mediationObserver.log(event)
//
////        completion?(waterfall.isEmpty ? .failure(.internalInconsistency) : .success(waterfall))
//    }
//
//    private func perform(round: RoundType) {
//        let pricefloor = 0.0
//
//        active.insert(round)
//
//        let event = MediationEvent.roundStart(
//            round: round,
//            pricefloor: pricefloor
//        )
//
//        mediationObserver.log(event)
//
//        round.onDemandRequest = { [unowned round, unowned self] adapter, lineItem in
//            self.round(round, didRequestDemand: adapter, lineItem: lineItem)
//        }
//
//        round.onDemandResponse = { [unowned round, unowned self] adapter, result in
//            switch result {
//            case .success((let provider, let ad, let lineItem)):
//                self.round(
//                    round,
//                    didReceive: ad,
//                    provider: provider,
//                    lineItem: lineItem,
//                    adapter: adapter
//                )
//            case .failure(let error):
//                self.round(
//                    round,
//                    didReceive: error,
//                    adapter: adapter
//                )
//            }
//        }
//
//        round.onRoundComplete = { [unowned round, unowned self] in
//            self.complete(round: round)
//        }
//
//        round.perform(pricefloor: pricefloor)
//    }
//
//    private func round(
//        _ round: RoundType,
//        didRequestDemand adapter: Adapter,
//        lineItem: LineItem?
//    ) {
//        let event = MediationEvent.bidRequest(
//            round: round,
//            adapter: adapter,
//            lineItem: lineItem
//        )
//
//        mediationObserver.log(event)
//    }
//
//    private func round(
//        _ round: RoundType,
//        didReceive ad: DemandAd,
//        provider: DemandProviderType,
//        lineItem: LineItem?,
//        adapter: Adapter
//    ) {
//        let bid = BidType(
//            auctionId: mediationObserver.auctionId,
//            auctionConfigurationId: mediationObserver.auctionConfigurationId,
//            roundId: round.id,
//            adType: mediationObserver.adType,
//            lineItem: lineItem,
//            ad: ad,
//            provider: provider
//        )
//
//        guard bid.eCPM > pricefloor else {
//            let event = MediationEvent.bidError(
//                round: round,
//                adapter: adapter,
//                error: .belowPricefloor
//            )
//            mediationObserver.log(event)
//            return
//        }
//
//        adRevenueObserver.observe(bid)
//        let event = MediationEvent.bidResponse(
//            round: round,
//            adapter: adapter,
//            bid: bid
//        )
//        mediationObserver.log(event)
//
//        bids.insert(bid)
//    }
//
//    private func round(
//        _ round: RoundType,
//        didReceive error: MediationError,
//        adapter: Adapter
//    ) {
//        let event = MediationEvent.bidError(
//            round: round,
//            adapter: adapter,
//            error: error
//        )
//        mediationObserver.log(event)
//    }
//
//    private func complete(round: RoundType) {
//        let event = MediationEvent.roundFinish(
//            round: round,
//            winner: nil
//        )
//        mediationObserver.log(event)
//
//        active.remove(round)
//
//        let seeds = auction.seeds(of: round)
//        if seeds.isEmpty && active.isEmpty {
//            finish()
//        } else {
//            seeds.forEach(perform)
//        }
//    }
}
