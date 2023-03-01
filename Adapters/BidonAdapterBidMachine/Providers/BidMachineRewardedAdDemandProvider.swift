//
//  BidMachineRewardedAdDemandProvider.swift
//  BidonAdapterBidMachine
//
//  Created by Bidon Team on 10.02.2023.
//

import Foundation
import UIKit
import BidMachine
import BidMachineApiCore
import Bidon


final class BidMachineRewardedAdDemandProvider: BidMachineBaseDemandProvider<BidMachineRewarded> {
    fileprivate typealias EmptyReward = RewardWrapper<NSNull>
    
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    override var placementFormat: BidMachineApiCore.PlacementFormat { .rewarded }
    
    override func didDismissAd(_ ad: BidMachineAdProtocol) {
        defer { super.didDismissAd(ad) }
        rewardDelegate?.provider(self, didReceiveReward: EmptyReward())
    }
}


extension BidMachineRewardedAdDemandProvider: RewardedAdDemandProvider {
    func show(
        ad: Ad,
        from viewController: UIViewController
    ) {
        guard
            let ad = ad as? BidMachineRewardedAdWrapper,
            ad.wrapped.canShow
        else {
            delegate?.providerDidFailToDisplay(self, error: .invalidPresentationState)
            return
        }
        
        ad.wrapped.controller = viewController
        ad.wrapped.presentAd()
    }
}


private extension BidMachineRewardedAdDemandProvider.EmptyReward {
    convenience init() {
        self.init(
            label: "",
            amount: .zero,
            wrapped: NSNull()
        )
    }
}
