//
//  BNMAAdReviewDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import MobileAdvertising


@objc public protocol BNMAAdReviewDelegate: AnyObject {
    func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: Ad) 
}
