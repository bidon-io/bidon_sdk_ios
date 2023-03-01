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
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    // TODO: Select format according to size
    override var placementFormat: BidMachineApiCore.PlacementFormat { .banner }
}


extension BidMachineAdViewDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        return (ad as? BidMachineBannerAdWrapper)?.wrapped
    }
}


extension BidMachineBanner: AdViewContainer {
    public var isAdaptive: Bool { false }
}
