//
//  BNLevelPlayRewardedVideoDelegate.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 13.07.2022.
//

import Foundation
import BidOn
import IronSource


@objc public protocol BNLevelPlayRewardedVideoDelegate {
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: Ad!)
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: Ad!)
    
    func didOpen(with adInfo: Ad!)
    
    func didClose(with adInfo: Ad!)
    
    func hasAvailableAd(with adInfo: Ad!)
    
    func hasNoAvailableAd()
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: Ad!)
}
