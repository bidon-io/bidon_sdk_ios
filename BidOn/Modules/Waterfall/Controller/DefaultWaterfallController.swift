//
//  WaterfallController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation



final class DefaultWaterfallController<T, M>: WaterfallController, MediationController
where T: Demand, T.Provider: DemandProvider, M: MediationObserver {
    
    typealias Observer = M
    typealias DemandType = T
    typealias DemandProviderType = T.Provider
    
    private var waterfall: Waterfall<DemandType>

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
            
            Logger.verbose("Provider \(demand.provider) will load bid: \(demand.ad)")
            
            self.observer.log(.fillRequest(ad: demand.ad))
            DispatchQueue.main.async {
                demand.provider.fill(ad: demand.ad) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.observer.log(.fillResponse(ad: demand.ad))
                        DispatchQueue.main.async {
                            Logger.verbose("Provider \(demand.provider) did load bid: \(demand.ad)")
                            completion(.success(demand))
                        }
                    case .failure(let error):
                        self.observer.log(.fillError(ad: demand.ad, error: error))
                        Logger.verbose("Provider \(demand.provider) did fail to load bid: \(demand.ad), error: \(error)")
                        self.recursivelyLoad(completion: completion)
                    }
                }
            }
        }
    }
}
