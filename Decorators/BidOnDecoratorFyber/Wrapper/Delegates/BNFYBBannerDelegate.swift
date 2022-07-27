//
//  BNFYBBannerDelegate.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import UIKit
import BidOn


@objc public protocol BNFYBBannerDelegate {
    func bannerDidLoad(_ banner: BNFYBBannerAdView)
    
    func bannerDidFail(toLoad placementId: String, withError error: Error)
    
    func bannerDidShow(_ banner: BNFYBBannerAdView, impressionData: Ad)
    
    func bannerDidClick(_ banner: BNFYBBannerAdView)
    
    func bannerWillPresentModalView(_ banner: BNFYBBannerAdView)
    
    func bannerDidDismissModalView(_ banner: BNFYBBannerAdView)
    
    func bannerWillLeaveApplication(_ banner: BNFYBBannerAdView)
    
    func banner(_ banner: BNFYBBannerAdView, didResizeToFrame frame: CGRect)
    
    func bannerWillRequest(_ placementId: String)
}

