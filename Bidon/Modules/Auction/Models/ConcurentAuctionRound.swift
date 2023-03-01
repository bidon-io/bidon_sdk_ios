//
//  ConcurrentAuctionRound.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 01.07.2022.
//

import Foundation


final class ConcurrentAuctionRound<DemandProviderType: DemandProvider>: PerformableAuctionRound {
    let id: String
    let timeout: TimeInterval
    let demands: [String]
    
    private let providers: [AnyAdapter: DemandProviderType]
    private let elector: LineItemElector
    
    private var pricefloor: Price = .unknown
    private var activeAdapters = Set<AnyAdapter>()
    private var timer: Timer?
    
    var onDemandRequest: AuctionRoundBidRequest?
    var onDemandResponse: AuctionRoundBidResponse<DemandProviderType>?
    var onRoundComplete: AuctionRoundCompletion?
    
    init(
        round: AuctionRound,
        elector: LineItemElector,
        providers: [AnyAdapter: DemandProviderType]
    ) {
        self.id = round.id
        self.timeout = round.timeout
        self.demands = round.demands
        self.providers = providers
        self.elector = elector
    }
    
    func perform(pricefloor: Price) {
        self.pricefloor = pricefloor
        scheduleInvalidationTimerIfNeeded()
        demands.forEach(proceed)
        completeIfNeeded()
    }
    
    private func proceed(_ id: String) {
        if let (adapter, provider) = providers.first(where: { $0.key.identifier == id }) {
            switch provider {
            case let programmatic as ProgrammaticDemandProvider:
                activeAdapters.insert(adapter)
                DispatchQueue.main.async { [unowned self] in
                    self.requestProgrammaticDemand(adapter: adapter, provider: programmatic)
                }
            case let direct as DirectDemandProvider:
                activeAdapters.insert(adapter)
                DispatchQueue.main.async { [unowned self] in
                    self.requestDirectDemand(adapter: adapter, provider: direct)
                }
            default:
                onDemandRequest?(adapter, nil)
                onDemandResponse?(adapter, .failure(.unknownAdapter))
            }
        } else {
            let adapter = AnyAdapter(identifier: id)
            onDemandRequest?(adapter, nil)
            onDemandResponse?(adapter, .failure(.unknownAdapter))
        }
    }
    
    private func requestProgrammaticDemand(
        adapter: AnyAdapter,
        provider: ProgrammaticDemandProvider
    ) {
        onDemandRequest?(adapter, nil)
        provider.bid(pricefloor) { [weak self] result in
            self?.handleDemandProviderResponse(
                adapter: adapter,
                result: result
            )
        }
    }
    
    private func requestDirectDemand(
        adapter: AnyAdapter,
        provider: DirectDemandProvider
    ) {
        if let lineItem = elector.lineItem(for: adapter.identifier, pricefloor: pricefloor) {
            onDemandRequest?(adapter, lineItem)
            provider.bid(lineItem) { [weak self] result in
                self?.handleDemandProviderResponse(
                    adapter: adapter,
                    result: result
                )
            }
        } else {
            onDemandRequest?(adapter, nil)
            onDemandResponse?(adapter, .failure(.noAppropriateAdUnitId))
            activeAdapters.remove(adapter)
        }
    }
    
    private func handleDemandProviderResponse(
        adapter: AnyAdapter,
        result: Result<Ad, MediationError>
    ) {
        activeAdapters.remove(adapter)
        
        switch result {
        case .success(let ad):
            if let provider = providers[adapter] {
                let bid = (ad, provider)
                onDemandResponse?(adapter, .success(bid))
            } else {
                onDemandResponse?(adapter, .failure(.noBid))
            }
        case .failure(let error):
            onDemandResponse?(adapter, .failure(error))
        }
        
        completeIfNeeded()
    }
    
    func cancel() {
        invalidateActiveAdapters(.auctionCancelled)
    }
    
    private func scheduleInvalidationTimerIfNeeded() {
        guard timeout.isNormal else { return }
        let interval = Date.MeasurementUnits.milliseconds.convert(timeout, to: .seconds)
        
        let timer = Timer(
            timeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.invalidateActiveAdapters(.bidTimeoutReached)
        }
        
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func invalidateActiveAdapters(_ error: MediationError) {
        activeAdapters.forEach { adapter in
            onDemandResponse?(adapter, .failure(error))
        }
        
        activeAdapters.removeAll()
        completeIfNeeded()
    }
    
    private func completeIfNeeded() {
        guard activeAdapters.isEmpty else { return }
        timer?.invalidate()
        onRoundComplete?()
    }
}


extension ConcurrentAuctionRound {
    static func == (lhs: ConcurrentAuctionRound, rhs: ConcurrentAuctionRound) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension ConcurrentAuctionRound: CustomStringConvertible {
    var description: String {
        return "Concurrent auction round \(id). " +
        "Timeout: \(timeout)s. Demands: " +
        demands.joined(separator: ", ")
    }
}
