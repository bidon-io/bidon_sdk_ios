//
//  WaterfallController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


final class WaterfallController<DemandType, MediationObserverType>: NSObject, MediationController
where DemandType: Demand, DemandType.Provider: DemandProvider, MediationObserverType: MediationObserver {
    private var waterfall: Waterfall<DemandType>

    let observer: MediationObserverType
    
    private let queue = DispatchQueue(
        label: "com.ads.waterfall.queue",
        qos: .default
    )
    
    init(
        _ waterfall: Waterfall<DemandType>,
        observer: MediationObserverType,
        timeout: TimeInterval
    ) {
        self.waterfall = waterfall
        self.observer = observer
        super.init()
    }
    
    func load(completion: @escaping (Result<DemandType, SdkError>) -> ()) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let demand = self.waterfall.next() else {
                DispatchQueue.main.async {
                    Logger.verbose("No bid to load")
                    completion(.failure(.noFill))
                }
                return
            }
            
            Logger.verbose("Provider \(demand.provider) will load bid: \(demand.ad)")
            
            DispatchQueue.main.async {
                demand.provider.load(ad: demand.ad) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            Logger.verbose("Provider \(demand.provider) did load bid: \(demand.ad)")
                            completion(.success(demand))
                        }
                    case .failure(let error):
                        Logger.verbose("Provider \(demand.provider) did fail to load bid: \(demand.ad), error: \(error)")
                        self.load(completion: completion)
                    }
                }
            }
        }
    }
}
