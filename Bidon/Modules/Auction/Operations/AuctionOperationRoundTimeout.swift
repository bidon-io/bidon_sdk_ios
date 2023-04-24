//
//  AuctionOperationRequestDemand.swift
//  Bidon
//
//  Created by Stas Kochkin on 24.04.2023.
//

import Foundation


protocol AuctionOperationRequestDemand {
    func timeoutReached() 
}


final class AuctionOperationRoundTimeout: AsynchronousOperation {
    private var timer: Timer?
    
    let interval: TimeInterval
    
    var operations: [AuctionOperationRequestDemand] = []
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func invalidate() {
        timer?.invalidate()
        finish()
    }
    
    override func main() {
        super.main()
        
        let timer = Timer(
            timeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.operations.forEach { $0.timeoutReached() }
            self?.finish()
        }
        
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
}
