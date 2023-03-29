//
//  InterstitialDemandProviderProtocol.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 05.07.2022.
//

import Foundation
import UIKit


public protocol InterstitialDemandProvider: DemandProvider {
    func show(ad: DemandAdType, from viewController: UIViewController)
}


internal extension InterstitialDemandProvider {
    func show(opaque ad: DemandAd, from viewController: UIViewController?) {
        guard let viewController = viewController ?? UIApplication.shared.bd.topViewcontroller else {
            let error = SdkError.unableToFindRootViewController
            delegate?.providerDidFailToDisplay(self, error: error)
            return
        }
        
        guard let ad = ad as? DemandAdType else {
            let error = SdkError.internalInconsistency
            delegate?.providerDidFailToDisplay(self, error: error)
            return
        }
        
        show(ad: ad, from: viewController)
    }
}

