//
//  BidMachineInterstitialDemandProvider.swift
//  BidonAdapterBidMachine
//
//  Created by Bidon Team on 10.02.2023.
//

import Foundation
import UIKit
import BidMachine
import BidMachineApiCore
import Bidon


final class BidMachineInterstitialDemandProvider: BidMachineBaseDemandProvider<BidMachineInterstitial> {
    override var placementFormat: BidMachineApiCore.PlacementFormat { .interstitial }
}


extension BidMachineInterstitialDemandProvider: InterstitialDemandProvider {
    func show(
        ad: Ad,
        from viewController: UIViewController
    ) {
        guard
            let ad = ad as? BidMachineInterstitialAdWrapper,
            ad.wrapped.canShow
        else {
            delegate?.providerDidFailToDisplay(self, error: .invalidPresentationState)
            return
        }
        
        ad.wrapped.controller = viewController
        ad.wrapped.presentAd()
    }
}
