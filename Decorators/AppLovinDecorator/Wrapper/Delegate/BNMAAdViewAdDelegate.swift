//
//  BNMAAdViewAdDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//


import Foundation
import MobileAdvertising


@objc public protocol BNMAAdViewAdDelegate: BNMAAdDelegate {
    func didExpand(_ ad: Ad)
    func didCollapse(_ ad: Ad)
}
