//
//  ConcurrentAuctionRound.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation


struct ConcurrentAuctionRound<DemandProviderType: DemandProvider>: PerformableAuctionRound {
    var id: String
    var timeout: TimeInterval
    var demands: [String]
    
    private var lineItems: LineItems
    private var providers: [String: DemandProviderType]
    
    private var group = DispatchGroup()
    private var completion: (() -> ())?
    private var isCancelled: Bool = false
    
    init(
        round: AuctionRound,
        lineItems: LineItems,
        providers: [String: DemandProviderType]
    ) {
        self.id = round.id
        self.timeout = round.timeout
        self.demands = round.demands
        self.lineItems = lineItems
        self.providers = providers
    }
    
    private func provider(_ demand: String) -> DemandProviderType? {
        return providers[demand]
    }
    
    func perform(
        pricefloor: Price,
        bid: @escaping AuctionRoundBidResponse<DemandProviderType>,
        completion: @escaping AuctionRoundCompletion
    ) {
        demands.forEach { id in
            group.enter()
            
            let response: DemandProviderResponse = { result in
                defer { group.leave() }
                guard let provider = provider(id) else { return }
                
                switch result {
                case .success(let ad):
                    bid(.success((ad, provider)))
                case .failure(let error):
                    bid(.failure(SdkError(error)))
                }
            }
            
            switch provider(id) {
            case let provider as ProgrammaticDemandProvider:
                Logger.verbose("Request programmatic bid for '\(id)' with pricefloor: \(pricefloor) through: \(provider)")
                DispatchQueue.main.async { [unowned provider] in
                    provider.bid(pricefloor, response: response)
                }
            case let provider as DirectDemandProvider:
                if let lineItem = lineItems.item(for: id, pricefloor: pricefloor) {
                    Logger.verbose("Request direct bid for '\(id)' with item: \(lineItem) through: \(provider)")
                    DispatchQueue.main.async { [unowned provider] in
                        provider.bid(lineItem, response: response)
                    }
                } else {
                    response(.failure(SdkError("Line Item for demand '\(id)' with pricefloor \(pricefloor) was not found")))
                }
            default:
                response(.failure(SdkError("Provider for demand '\(id)' was not found")))
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func cancel() {
        demands
            .compactMap(provider)
            .forEach { $0.cancel() }
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
