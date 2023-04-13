//
//  BidMachineAdViewDemandSourceAdapter.swift
//  BidonAdapterBidMachine
//
//  Created by Bidon Team on 10.02.2023.
//

import Foundation
import UIKit
import BidMachineApiCore
import BidMachine
import Bidon


final class BidMachineAdViewDemandProvider: BidMachineBaseDemandProvider<BidMachineBanner> {
    private let format: BannerFormat
    
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    override var placementFormat: BidMachineApiCore.PlacementFormat { .init(format: format) }
    
    init(context: AdViewContext) {
        self.format = context.format
        
        super.init()
    }
}


extension BidMachineAdViewDemandProvider: AdViewDemandProvider {
    func container(for ad: BidMachineAdDemand<BidMachineBanner>) -> AdViewContainer? {
        return ad.ad
    }
}


extension BidMachineBanner: AdViewContainer {
    public var isAdaptive: Bool { false }
}


extension BidMachineApiCore.PlacementFormat {
    init(format: BannerFormat) {
        switch format {
        case .banner: self = .banner320x50
        case .leaderboard: self = .banner728x90
        case .adaptive: self = .banner
        case .mrec: self = .banner300x250
        }
    }
}
