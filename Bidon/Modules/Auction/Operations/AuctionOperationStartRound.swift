//
//  StartAuctionRoundOperation.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


final class AuctionOperationStartRound<BidType: Bid>: Operation
where BidType.Provider: DemandProvider {
    var pricefloor: Price {
        let initial = deps(ConcurrentAuctionStartOperation.self).first?.pricefloor ?? .unknown
        let latest = deps(AuctionOperationFinishRound<BidType>.self).last?.winner?.eCPM ?? .unknown
        
        return max(initial, latest)
    }
    
    let round: AuctionRound
    let observer: AnyMediationObserver
    
    init(
        observer: AnyMediationObserver,
        round: AuctionRound
    ) {
        self.observer = observer
        self.round = round
        super.init()
    }
    
    override func main() {
        super.main()
        
        let event = MediationEvent.roundStart(
            round: round,
            pricefloor: pricefloor
        )
        
        observer.log(event)
    }
}


extension AuctionOperationStartRound: AuctionOperation {}
