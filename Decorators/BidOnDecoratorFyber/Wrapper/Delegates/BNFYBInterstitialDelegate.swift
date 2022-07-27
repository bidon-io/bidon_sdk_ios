//
//  BNFYBInterstitialDelegate.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import BidOn


@objc public protocol BNFYBInterstitialDelegate {
    func interstitialWillRequest(_ placementId: String)
    
    func interstitialIsAvailable(_ placementId: String)
    
    func interstitialIsUnavailable(_ placementId: String)
    
    func interstitialDidShow(_ placementId: String, impressionData: Ad)
    
    func interstitialDidFail(toShow placementId: String, withError error: Error, impressionData: Ad)
    
    func interstitialDidClick(_ placementId: String)
    
    func interstitialDidDismiss(_ placementId: String)
}
