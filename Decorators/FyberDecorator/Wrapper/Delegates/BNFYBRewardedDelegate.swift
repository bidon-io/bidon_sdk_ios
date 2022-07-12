//
//  BNFYBRewardedDelegate.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import MobileAdvertising


@objc public protocol BNFYBRewardedDelegate {
    func rewardedIsAvailable(_ placementName: String)
    
    func rewardedIsUnavailable(_ placementName: String)
    
    func rewardedDidShow(_ placementName: String, impressionData: Ad)
    
    func rewardedDidFail(toShow placementName: String, withError error: Error, impressionData: Ad)
    
    func rewardedDidClick(_ placementName: String)
    
    func rewardedDidComplete(_ placementName: String, userRewarded: Bool)
    
    func rewardedDidDismiss(_ placementName: String)
    
    func rewardedWillRequest(_ placementId: String)
}
