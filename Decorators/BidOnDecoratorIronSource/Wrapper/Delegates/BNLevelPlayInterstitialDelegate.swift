//
//  BNLevelPlayInterstitialDelegate.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 13.07.2022.
//

import Foundation
import BidOn


@objc public protocol BNLevelPlayInterstitialDelegate {
    func didLoad(with adInfo: Ad!)
    
    func didFailToLoadWithError(_ error: Error!)
    
    func didOpen(with adInfo: Ad!)
    
    func didShow(with adInfo: Ad!)
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: Ad!)
    
    func didClick(with adInfo: Ad!)
    
    func didClose(with adInfo: Ad!)
}
