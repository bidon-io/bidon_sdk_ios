//
//  BidMachineBiddingInterstitialDemandProvider.swift
//  BidonAdapterBidMachine
//
//  Created by Stas Kochkin on 31.05.2023.
//

import Foundation
import UIKit
import BidMachine
import BidMachineApiCore
import Bidon


final class BidMachineInterstitialBiddingDemandProvider: BidMachineBiddingDemandProvider<BidMachineInterstitial> {
    override var placementFormat: BidMachineApiCore.PlacementFormat { .interstitial }
}


extension BidMachineInterstitialBiddingDemandProvider: InterstitialDemandProvider {
    func show(ad: BidMachineAdDemand<BidMachineInterstitial>, from viewController: UIViewController) {
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
