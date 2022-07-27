//
//  BNISBannerDelegate.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import BidOn
import UIKit


@objc public protocol BNISBannerDelegate {
    func bannerDidLoad(_ bannerView: UIView)
    
    func bannerDidFailToLoadWithError(_ error: Error)

    func didClickBanner()

    func bannerWillPresentScreen()

    func bannerDidDismissScreen()

    func bannerWillLeaveApplication()
}
