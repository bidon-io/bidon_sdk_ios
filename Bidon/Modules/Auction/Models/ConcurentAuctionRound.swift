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
    
    private let adapters: [AnyDemandSourceAdapter<DemandProviderType>]
    private let elector: LineItemElector
    
    private var pricefloor: Price = .unknown
    private var timer: Timer?
    private var activeAdaptersIdentifiers = Set<String>()
    
    var onDemandRequest: AuctionRoundDemandRequest?
    var onDemandResponse: AuctionRoundDemandResponse<DemandProviderType>?
    var onRoundComplete: AuctionRoundCompletion?
    
    init(
        round: AuctionRound,
        elector: LineItemElector,
        adapters: [AnyDemandSourceAdapter<DemandProviderType>]
    ) {
        self.id = round.id
        self.timeout = round.timeout
        self.demands = round.demands
        self.adapters = adapters
        self.elector = elector
    }
    
    func perform(pricefloor: Price) {
        self.pricefloor = pricefloor
        scheduleInvalidationTimerIfNeeded()
        demands.forEach(proceed)
        completeIfNeeded()
    }
    
    private func proceed(_ id: String) {
        guard let adapter = adapters.first(where: { $0.identifier == id }) else {
            let adapter = UnknownAdapter(identifier: id)
            onDemandRequest?(adapter, nil)
            onDemandResponse?(adapter, .failure(.unknownAdapter))
            return
        }
        
        switch adapter.provider {
        case let programmatic as any ProgrammaticDemandProvider:
            activeAdaptersIdentifiers.insert(id)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.onDemandRequest?(adapter, nil)
                programmatic.bid(self.pricefloor) { [weak self] result in
                    self?.handleDemandProviderResponse(
                        adapter: adapter,
                        result: result
                    )
                }
            }
        case let direct as any DirectDemandProvider:
            if let lineItem = elector.lineItem(for: adapter.identifier, pricefloor: pricefloor) {
                activeAdaptersIdentifiers.insert(id)
                DispatchQueue.main.async { [weak self] in
                    self?.onDemandRequest?(adapter, lineItem)
                    direct.bid(lineItem) { [weak self] result in
                        self?.handleDemandProviderResponse(
                            adapter: adapter,
                            lineItem: lineItem,
                            result: result
                        )
                    }
                }
            } else {
                onDemandRequest?(adapter, nil)
                onDemandResponse?(adapter, .failure(.noAppropriateAdUnitId))
            }
        default:
            onDemandRequest?(adapter, nil)
            onDemandResponse?(adapter, .failure(.unknownAdapter))
        }
    }
    
    
    private func handleDemandProviderResponse(
        adapter: AnyDemandSourceAdapter<DemandProviderType>,
        lineItem: LineItem? = nil,
        result: Result<DemandAd, MediationError>
    ) {
        activeAdaptersIdentifiers.remove(adapter.identifier)
        
        switch result {
        case .success(let ad):
            onDemandResponse?(adapter, .success((adapter.provider, ad, lineItem)))
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
        activeAdaptersIdentifiers.forEach { identifier in
            if let adapter = adapters.first(where: { $0.identifier == identifier }) {
                onDemandResponse?(adapter, .failure(error))
            }
        }
        
        activeAdaptersIdentifiers.removeAll()
        completeIfNeeded()
    }
    
    private func completeIfNeeded() {
        guard activeAdaptersIdentifiers.isEmpty else { return }
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
