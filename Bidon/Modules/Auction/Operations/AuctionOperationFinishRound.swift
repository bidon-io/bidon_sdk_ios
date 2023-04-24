//
//  FinishRoundOperation.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


final class AuctionOperationFinishRound<BidType: Bid>: Operation
where BidType.Provider: DemandProvider {
    let observer: AnyMediationObserver
    let round: AuctionRound
    let comparator: AuctionBidComparator
    
    private(set) var winner: BidType?
    
    init(
        observer: AnyMediationObserver,
        round: AuctionRound,
        comparator: AuctionBidComparator
    ) {
        self.observer = observer
        self.round = round
        self.comparator = comparator
        super.init()
    }
    
    private var directBids: [BidType] {
        deps(ConcurrentAuctionRequestDirectDemandOperation<BidType.Provider>.self)
            .compactMap { $0.bid as? BidType }
    }
    
    private var programmaticBids: [BidType] {
        deps(ConcurrentAuctionRequestProgrammaticDemandOperation<BidType.Provider>.self)
            .compactMap { $0.bid as? BidType }
    }
    
    override func main() {
        super.main()
        
        winner = (directBids + programmaticBids)
            .sorted { comparator.compare($0, $1) }
            .first

        let event = MediationEvent.roundFinish(
            round: round,
            winner: winner
        )
        
        observer.log(event)
    }
}


extension AuctionOperationFinishRound: AuctionOperation {}
