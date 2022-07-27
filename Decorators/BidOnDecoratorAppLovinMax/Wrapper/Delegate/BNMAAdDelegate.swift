//
//  BNMAAdDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import BidOn


@objc public protocol BNMAAdDelegate: AnyObject {
    @objc(didLoadAd:)
    func didLoad(_ ad: Ad)
    
    @objc
    func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String,
        withError error: Error
    )
    
    @objc(didDisplayAd:)
    func didDisplay(_ ad: Ad)
    
    @objc(didHideAd:)
    func didHide(_ ad: Ad)
    
    @objc(didClickAd:)
    func didClick(_ ad: Ad)
    
    @objc(didFailToDisplayAd:withError:)
    func didFail(
        toDisplay ad: Ad,
        withError error: Error
    )
}

