//
//  BNLevelPlayBannerDelegate.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import MobileAdvertising
import UIKit


@objc public protocol BNLevelPlayBannerDelegate{
    func didLoad(_ bannerView: UIView!, with adInfo: Ad!)
    
    func didFailToLoadWithError(_ error: Error!)
    
    func didClick(with adInfo: Ad!)
    
    func didLeaveApplication(with adInfo: Ad!)
    
    func didPresentScreen(with adInfo: Ad!)
    
    func didDismissScreen(with adInfo: Ad!)
}
