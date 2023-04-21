//
//  FinishRoundOperation.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


final class ConcurrentAuctionFinishRoundOperation<BidType: Bid>: Operation
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
    
    override func main() {
        super.main()
        
        winner = deps(ConcurrentAuctionRequestDemandOperation<BidType.Provider>.self)
            .compactMap { $0.bid }
            .sorted { comparator.compare($0, $1) }
            .first as? BidType

        let event = MediationEvent.roundFinish(
            round: round,
            winner: winner
        )
        
        observer.log(event)
    }
}
