//
//  RequestDirectDemandOperation.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation



#warning("Split")
#warning("Set revenue delegate")
final class ConcurrentAuctionRequestDemandOperation<DemandProviderType: DemandProvider>: AsynchronousOperation {
    typealias BidType = BidModel<DemandProviderType>
    typealias AdapterType = AnyDemandSourceAdapter<DemandProviderType>
    
    let round: AuctionRound
    let observer: AnyMediationObserver
    let adapter: AnyDemandSourceAdapter<DemandProviderType>
    
    let lineItem: (AdapterType, Price) -> LineItem?
    
    private(set) var bid: BidType?
    
    private var pricefloor: Price {
        deps(ConcurrentAuctionStartRoundOperation<BidType>.self)
            .first?
            .pricefloor ?? .unknown
    }
    
    init(
        round: AuctionRound,
        observer: AnyMediationObserver,
        adapter: AnyDemandSourceAdapter<DemandProviderType>,
        lineItem: @escaping (AdapterType, Price) -> LineItem?
    ) {
        self.round = round
        self.observer = observer
        self.adapter = adapter
        self.lineItem = lineItem
        
        super.init()
    }
    
    override func main() {
        super.main()
        
        switch adapter.provider {
        case let provider as any ProgrammaticDemandProvider:
            bid(programmatic: provider)
        case let provider as any DirectDemandProvider:
            load(direct: provider)
        default:
            finish()
        }
    }
    
    private func bid(programmatic provider: any ProgrammaticDemandProvider) {
        let event = MediationEvent.bidRequest(
            round: round,
            adapter: adapter
        )
        

        observer.log(event)
        provider.bid(pricefloor) { [weak self, unowned provider] result in
            guard let self = self, self.isExecuting else { return }
            
            switch result {
            case .failure(let error):
                let event = MediationEvent.bidError(
                    round: self.round,
                    adapter: self.adapter,
                    error: error
                )
                
                self.observer.log(event)
                self.finish()
            case .success(let ad):
                let bid = BidType(
                    auctionId: self.observer.auctionId,
                    auctionConfigurationId: self.observer.auctionConfigurationId,
                    roundId: self.round.id,
                    adType: self.observer.adType,
                    ad: ad,
                    provider: self.adapter.provider
                )
                
                let event = MediationEvent.bidResponse(
                    round: self.round,
                    adapter: self.adapter,
                    bid: bid
                )
                
                self.observer.log(event)
                self.fill(programmatic: provider, bid: bid)
            }
        }
    }
    
    private func fill(programmatic provider: any ProgrammaticDemandProvider, bid: BidType) {
        provider.fill(opaque: bid.ad) { [weak self] result in
            guard let self = self, self.isExecuting else { return }
            
            switch result {
            case .failure(let error):
                let event = MediationEvent.fillError(
                    round: self.round,
                    adapter: self.adapter,
                    bid: bid,
                    error: error
                )
                
                self.observer.log(event)
                self.finish()
            case .success(let ad):
                let bid = BidType(
                    auctionId: self.observer.auctionId,
                    auctionConfigurationId: self.observer.auctionConfigurationId,
                    roundId: self.round.id,
                    adType: self.observer.adType,
                    ad: ad,
                    provider: self.adapter.provider
                )
                
                let event = MediationEvent.fillResponse(
                    round: self.round,
                    adapter: self.adapter,
                    bid: bid
                )
                
                self.observer.log(event)
                self.bid = bid
                self.finish()
            }
        }
    }
    
    private func load(direct provider: any DirectDemandProvider) {
        guard let lineItem = lineItem(adapter, pricefloor) else {
            let event = MediationEvent.lineItemNotFound(
                round: round,
                adapter: adapter
            )
            observer.log(event)
            finish()
            return
        }
        
        let event = MediationEvent.loadRequest(
            round: round,
            adapter: adapter,
            lineItem: lineItem
        )
        
        observer.log(event)
        
        provider.load(lineItem.adUnitId) { [weak self] result in
            guard let self = self, self.isExecuting else { return }
            
            switch result {
            case .failure(let error):
                let event = MediationEvent.loadError(
                    round: self.round,
                    adapter: self.adapter,
                    error: error
                )
                self.observer.log(event)
                self.finish()
            case .success(let ad):
                let bid = BidType(
                    auctionId: self.observer.auctionId,
                    auctionConfigurationId: self.observer.auctionConfigurationId,
                    roundId: self.round.id,
                    adType: self.observer.adType,
                    ad: ad,
                    provider: self.adapter.provider
                )
                
                let event = MediationEvent.loadResponse(
                    round: self.round,
                    adapter: self.adapter,
                    bid: bid
                )
                
                self.observer.log(event)
                self.bid = bid
                self.finish()
            }
            
        }
    }
}
