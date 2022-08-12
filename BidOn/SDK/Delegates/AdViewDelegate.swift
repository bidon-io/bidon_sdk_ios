//
//  BannerViewDelegate.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation
import UIKit


@objc(BDAdView)
public protocol AdView: AdObject {}


@objc(BDAdViewDelegate)
public protocol AdViewDelegate: AdObjectDelegate {
    func adView(
        _ adView: AdView & UIView,
        willPresentScreen ad: Ad
    )
    
    func adView(
        _ adView: AdView & UIView,
        didDismissScreen ad: Ad
    )
    
    func adView(
        _ adView: AdView & UIView,
        willLeaveApplication ad: Ad
    )
}
