//
//  BidMachineBiddingRewardedAdDemandProvider.swift
//  BidonAdapterBidMachine
//
//  Created by Stas Kochkin on 01.06.2023.
//

import Foundation
import UIKit
import BidMachine
import BidMachineApiCore
import Bidon


final class BidMachineBiddingRewardedAdDemandProvider: BidMachineBiddingDemandProvider<BidMachineRewarded> {    
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    override var placementFormat: BidMachineApiCore.PlacementFormat { .rewarded }
    
    override func didDismissAd(_ ad: BidMachineAdProtocol) {
        defer { super.didDismissAd(ad) }
        
        rewardDelegate?.provider(self, didReceiveReward: BidMachineEmptyReward())
    }
}


extension BidMachineBiddingRewardedAdDemandProvider: RewardedAdDemandProvider {
    func show(
        ad: BidMachineAdDemand<BidMachineRewarded>,
        from viewController: UIViewController
    ) {
        guard ad.ad.canShow else {
            delegate?.provider(
                self,
                didFailToDisplayAd: ad,
                error: .invalidPresentationState
            )
            return
        }
        
        ad.ad.controller = viewController
        ad.ad.presentAd()
    }
}
