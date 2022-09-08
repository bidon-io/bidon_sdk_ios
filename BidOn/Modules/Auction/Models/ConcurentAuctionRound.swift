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
    private var providers: [AnyAdapter: DemandProviderType]
    
    private var group = DispatchGroup()
    private var completion: (() -> ())?
    private var isCancelled: Bool = false
    
    init(
        round: AuctionRound,
        lineItems: LineItems,
        providers: [AnyAdapter: DemandProviderType]
    ) {
        self.id = round.id
        self.timeout = round.timeout
        self.demands = round.demands
        self.lineItems = lineItems
        self.providers = providers
    }
    
    private func pair(_ networkId: String) -> (adapter: AnyAdapter, provider: DemandProviderType)? {
        return providers
            .first { adapter, provider in
                adapter.identifier == networkId
            }
            .map { ($0.key, $0.value) }
    }
    
    func perform(
        pricefloor: Price,
        request: @escaping AuctionRoundBidRequest,
        response: @escaping AuctionRoundBidResponse<DemandProviderType>,
        completion: @escaping AuctionRoundCompletion
    ) {
        for networkId in demands {
            group.enter()
            
            guard let provider = pair(networkId) else {
                let adapter = AnyAdapter(identifier: networkId)
                request(adapter, nil)
                response(adapter, .failure(.unknownAdapter))
                group.leave()
                continue
            }
            
            let providerResponseHandler: DemandProviderResponse = { result in
                defer { group.leave() }
                
                switch result {
                case .success(let ad):
                    let bid = (ad, provider.provider)
                    response(provider.adapter, .success(bid))
                case .failure(let error):
                    response(provider.adapter, .failure(error))
                }
            }
            
            switch provider.provider {
            case let programmatic as ProgrammaticDemandProvider:
                DispatchQueue.main.async {
                    request(provider.adapter, nil)
                    programmatic.bid(pricefloor, response: providerResponseHandler)
                }
            case let direct as DirectDemandProvider:
                if let lineItem = lineItems.item(for: provider.adapter.identifier, pricefloor: pricefloor) {
                    DispatchQueue.main.async {
                        request(provider.adapter, lineItem)
                        direct.bid(lineItem, response: providerResponseHandler)
                    }
                } else {
                    request(provider.adapter, nil)
                    response(provider.adapter, .failure(.noApproperiateAdUnitId))
                    group.leave()
                }
            default:
                request(provider.adapter, nil)
                response(provider.adapter, .failure(.unknownAdapter))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func destroy() {
        demands
            .compactMap(pair)
            .forEach { $0.provider.cancel(.lifecycle) }
    }
    
    func timeoutReached() {
        demands
            .compactMap(pair)
            .forEach { $0.provider.cancel(.timeoutReached) }
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
