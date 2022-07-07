//
//  InterstitialDemandProviderProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import UIKit


public protocol InterstitialDemandProvider: DemandProvider {
    func show(ad: Ad, from viewController: UIViewController)
}


public extension InterstitialDemandProvider {
    func _show(ad: Ad, from viewController: UIViewController?) {
        if let viewController = viewController ?? UIApplication.shared.topViewContoller {
            show(ad: ad, from: viewController)
        } else {
            delegate?.provider(
                self,
                didFailToDisplay: ad,
                error: SDKError.unableToFindRootViewController
            )
        }
    }
}

