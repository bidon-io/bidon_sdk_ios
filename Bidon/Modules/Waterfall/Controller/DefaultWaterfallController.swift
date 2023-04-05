//
//  WaterfallController.swift
//  Bidon
//
//  Created by Bidon Team on 16.08.2022.
//

import Foundation



final class DefaultWaterfallController<T>: WaterfallController
where T: Bid, T.Provider: DemandProvider {
    
    typealias BidType = T
    typealias DemandProviderType = T.Provider
    
    private var waterfall: Waterfall<BidType>
    private var timer: Timer?
    
    let timeout: TimeInterval
    let observer: any MediationObserver
    
    var bids: [T] { Array(waterfall: waterfall) }
    
    private let queue = DispatchQueue(
        label: "com.bidon.waterfall.queue",
        qos: .default
    )
    
    init(
        _ waterfall: Waterfall<BidType>,
        observer: AnyMediationObserver,
        timeout: TimeInterval
    ) {
        self.timeout = timeout
        self.waterfall = waterfall
        self.observer = observer
    }
    
    func load(completion: @escaping (Result<BidType, SdkError>) -> ()) {
        let event = MediationEvent.fillStart
        observer.log(event)
        
        recursivelyLoad(completion: completion)
    }
    
    private func recursivelyLoad(completion: @escaping (Result<BidType, SdkError>) -> ()) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let bid = self.waterfall.next() else {
                self.observer.log(.fillFinish(winner: nil))
                DispatchQueue.main.async {
                    completion(.failure(.noFill))
                }
                return
            }
            
            var isFinished = false
            
            let interval = Date.MeasurementUnits.milliseconds.convert(self.timeout, to: .seconds)
            if interval.isNormal {
                self.timer?.invalidate()
                let timer = Timer(
                    timeInterval: interval,
                    repeats: false
                ) { [weak self] _ in
                    defer { isFinished = true }
                    guard !isFinished, let self = self else { return }
                    
                    let event = MediationEvent.fillError(
                        bid: bid,
                        error: .fillTimeoutReached
                    )
                    self.observer.log(event)
                    
                    self.recursivelyLoad(completion: completion)
                }
                
                RunLoop.main.add(timer, forMode: .common)
                self.timer = timer
            }
            
            let event = MediationEvent.fillRequest(bid: bid)
            self.observer.log(event)
            
            DispatchQueue.main.async {
                bid.provider.fill(opaque: bid.ad) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        defer { isFinished = true }
                        guard !isFinished else { return }
                                                
                        let event = MediationEvent.fillResponse(bid: bid)
                        self.observer.log(event)
                        
                        // Notify providers
                        bid.provider.notify(opaque: bid.ad, event: .win)
                        while let loser = self.waterfall.next() {
                            loser.provider.notify(
                                opaque: loser.ad,
                                event: .lose(bid.ad, bid.eCPM)
                            )
                        }
                        
                        DispatchQueue.main.async {
                            completion(.success(bid))
                        }
                    case .failure(let error):
                        defer { isFinished = true }
                        guard !isFinished else { return }
                        
                        let event = MediationEvent.fillError(bid: bid, error: error)
                        self.observer.log(event)
                        
                        self.recursivelyLoad(completion: completion)
                    }
                }
            }
        }
    }
}
