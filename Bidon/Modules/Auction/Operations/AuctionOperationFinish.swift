//
//  FinishAuctionOperation.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


final class AuctionOperationFinish<BidType: Bid>: Operation
where BidType.Provider: DemandProvider {
    let observer: AnyMediationObserver
    let completion: (Result<BidType, SdkError>) -> ()
    
    init(
        observer: AnyMediationObserver,
        completion: @escaping (Result<BidType, SdkError>) -> ()
    ) {
        self.observer = observer
        self.completion = completion
    }
    
    override func main() {
        super.main()
        #warning("Finish auction")
//        observer.log(.auctionFinish(winner: <#T##(Bid)?#>))
    }
}


extension AuctionOperationFinish: AuctionOperation {}
