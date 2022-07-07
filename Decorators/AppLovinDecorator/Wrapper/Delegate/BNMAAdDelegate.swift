//
//  BNMAAdDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import MobileAdvertising


@objc public protocol BNMAAdDelegate: AnyObject {
    func didLoad(_ ad: Ad)
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: Error)
    func didDisplay(_ ad: Ad)
    func didHide(_ ad: Ad)
    func didClick(_ ad: Ad)
    func didFail(toDisplay ad: Ad, withError error: Error)
}

