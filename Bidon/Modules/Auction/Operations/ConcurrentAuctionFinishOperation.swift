//
//  FinishAuctionOperation.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


final class ConcurrentAuctionFinishOperation<BidType: Bid>: Operation {
    let observer: AnyMediationObserver
//    let completion:
    
    init(observer: AnyMediationObserver) {
        self.observer = observer
    }
    
    override func main() {
        super.main()
        #warning("Finish auction")
//        observer.log(.auctionFinish(winner: <#T##(Bid)?#>))
    }
}
