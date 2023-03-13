//
//  WaterfallController.swift
//  Bidon
//
//  Created by Bidon Team on 16.08.2022.
//

import Foundation



final class DefaultWaterfallController<T, M>: WaterfallController, MediationController
where T: Demand, T.Provider: DemandProvider, M: MediationObserver {
    
    typealias Observer = M
    typealias DemandType = T
    typealias DemandProviderType = T.Provider
    
    private var waterfall: Waterfall<DemandType>
    private var timer: Timer?
    
    let timeout: TimeInterval
    let observer: Observer
    
    private let queue = DispatchQueue(
        label: "com.ads.waterfall.queue",
        qos: .default
    )
    
    init(
        _ waterfall: Waterfall<DemandType>,
        observer: Observer,
        timeout: TimeInterval
    ) {
        self.timeout = timeout
        self.waterfall = waterfall
        self.observer = observer
    }
    
    func load(completion: @escaping (Result<DemandType, SdkError>) -> ()) {
        observer.log(.fillStart)
        recursivelyLoad(completion: completion)
    }
    
    private func recursivelyLoad(completion: @escaping (Result<DemandType, SdkError>) -> ()) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let demand = self.waterfall.next() else {
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
                    print("BLUSSDsds`d")
                    defer { isFinished = true }
                    guard !isFinished, let self = self else { return }
                    
                    self.observer.log(.fillError(ad: demand.ad, error: .fillTimeoutReached))
                    Logger.verbose("Provider \(demand.provider) did fail to load bid: \(demand.ad), error: \(MediationError.fillTimeoutReached)")
                    self.recursivelyLoad(completion: completion)
                }
                
                RunLoop.main.add(timer, forMode: .common)
                self.timer = timer
            }
            
            Logger.verbose("Provider \(demand.provider) will load bid: \(demand.ad), timeout: \(interval)")
            self.observer.log(.fillRequest(ad: demand.ad))
            
            DispatchQueue.main.async {
                demand.provider._fill(ad: demand.ad) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        defer { isFinished = true }
                        guard !isFinished else { return }
                        
                        self.observer.log(.fillResponse(ad: demand.ad))
                        DispatchQueue.main.async {
                            Logger.verbose("Provider \(demand.provider) did load bid: \(demand.ad)")
                            completion(.success(demand))
                        }
                    case .failure(let error):
                        defer { isFinished = true }
                        guard !isFinished else { return }
                        
                        self.observer.log(.fillError(ad: demand.ad, error: error))
                        Logger.verbose("Provider \(demand.provider) did fail to load bid: \(demand.ad), error: \(error)")
                        self.recursivelyLoad(completion: completion)
                    }
                }
            }
        }
    }
}
