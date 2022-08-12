//
//  FullscreenAdDelegate.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation

@objc(BDFullscreenAd)
public protocol FullscreenAd: AdObject {}


@objc(BDFullscreenAdDelegate)
public protocol FullscreenAdDelegate: AdObjectDelegate {
    func fullscreenAd(_ fullscreenAd: FullscreenAd, willPresentAd ad: Ad)
    
    func fullscreenAd(_ fullscreenAd: FullscreenAd, didFailToPresentAd error: Error)
    
    func fullscreenAd(_ fullscreenAd: FullscreenAd, didDismissAd ad: Ad)
}
