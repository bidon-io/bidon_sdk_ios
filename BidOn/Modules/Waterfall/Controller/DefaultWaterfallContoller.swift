//
//  DefaultWaterfallcontroller.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


final class DefaultWaterfallController: NSObject, WaterfallController {
    weak var delegate: WaterfallControllerDelegate?
    
    private var waterfall: Waterfall
    
    private let queue = DispatchQueue(
        label: "com.ads.waterfall.queue",
        qos: .default
    )
    
    init(
        _ waterfall: Waterfall,
        timeout: TimeInterval
    ) {
        self.waterfall = waterfall
        super.init()
    }
    
    func load() {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let demand = self.waterfall.next() else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    Logger.verbose("No bid to load")
                    self.delegate?.controller(self, didFailToLoad: .noFill)
                }
                return
            }
            
            Logger.verbose("Provider \(demand.provider) will load bid: \(demand.ad)")
            
            DispatchQueue.main.async {
                demand.provider.load(ad: demand.ad) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            Logger.verbose("Provider \(demand.provider) did load bid: \(demand.ad)")
                            self.delegate?.controller(self, didLoadDemand: demand)
                        }
                    case .failure(let error):
                        Logger.verbose("Provider \(demand.provider) did fail to load bid: \(demand.ad), error: \(error)")
                        self.load()
                    }
                }
            }
        }
    }
}
