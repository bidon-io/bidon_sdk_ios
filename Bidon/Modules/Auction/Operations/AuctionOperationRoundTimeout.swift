//
//  AuctionOperationRequestDemand.swift
//  Bidon
//
//  Created by Stas Kochkin on 24.04.2023.
//

import Foundation


protocol AuctionOperationRequestDemand: Operation {
    func timeoutReached() 
}


final class AuctionOperationRoundTimeout: AsynchronousOperation {
    private var timer: Timer?
    
    let interval: TimeInterval
    let observer: AnyMediationObserver

    private var operations = NSHashTable<Operation>.weakObjects()
    
    init(
        observer: AnyMediationObserver,
        interval: TimeInterval
    ) {
        self.observer = observer

        self.interval = Date.MeasurementUnits.milliseconds.convert(interval, to: .seconds)
        
        super.init()
    }
    
    func invalidate() {
        observer.log(.invalidateRoundTimer)
        timer?.invalidate()
        finish()
    }
    
    func add(_ operation: Operation) {
        operations.add(operation)
    }
    
    override func main() {
        super.main()
        
        guard interval > 0 else {
            finish()
            return
        }
        
        observer.log(.scheduleRoundTimer(interval: interval))
        
        let timer = Timer(
            timeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.observer.log(.roundTimerFired)
            self?.operations
                .allObjects
                .compactMap { $0 as? AuctionOperationRequestDemand }
                .forEach { $0.timeoutReached() }
            
            self?.finish()
        }
        
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
}
