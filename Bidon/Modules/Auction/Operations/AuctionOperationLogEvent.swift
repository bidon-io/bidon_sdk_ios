//
//  AuctionOperationLogEvent.swift
//  Bidon
//
//  Created by Stas Kochkin on 24.04.2023.
//

import Foundation


final class AuctionOperationLogEvent: Operation {
    let observer: AnyMediationObserver
    let event: MediationEvent
    
    init(
        observer: AnyMediationObserver,
        event: MediationEvent
    ) {
        self.event = event
        self.observer = observer
        super.init()
    }
    
    override func main() {
        super.main()
        observer.log(event)
    }
}


extension AuctionOperationLogEvent: AuctionOperation {}
