//
//  InterstitialDemandProviderProtocol.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 05.07.2022.
//

import Foundation
import UIKit


public protocol InterstitialDemandProvider: DemandProvider {
    func show(ad: AdType, from viewController: UIViewController)
}


internal extension InterstitialDemandProvider {
    func _show(ad: Ad, from viewController: UIViewController?) {
        guard let viewController = viewController ?? UIApplication.shared.bd.topViewcontroller else {
            delegate?.providerDidFailToDisplay(self, error: SdkError.unableToFindRootViewController)
            return
        }
        
        guard let ad = ad as? AdType else {
            delegate?.providerDidFailToDisplay(self, error: SdkError.internalInconsistency)
            return
        }
        
        show(ad: ad, from: viewController)
    }
}

