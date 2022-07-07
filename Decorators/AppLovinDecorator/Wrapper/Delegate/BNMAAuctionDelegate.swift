//
//  BNMAAuctionDelegate.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import MobileAdvertising


@objc public protocol BNMAuctionDelegate: AnyObject {
    func didStartAuction()
    func didStartAuctionRound(_ round: String, pricefloor: Price)
    func didReceiveAd(_ ad: Ad)
    func didCompleteAuctionRound(_ round: String)
    func didCompleteAuction(_ winner: Ad?)
}

