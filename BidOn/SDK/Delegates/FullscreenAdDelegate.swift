//
//  FullscreenAdDelegate.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation

@objc(BDNFullscreenAd)
public protocol FullscreenAdObject: AdObject {}


@objc(BDNFullscreenAdDelegate)
public protocol FullscreenAdDelegate: AdObjectDelegate {
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, willPresentAd ad: Ad)
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, didFailToPresentAd error: Error)
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, didDismissAd ad: Ad)
}
