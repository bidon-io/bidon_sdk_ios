//
//  BNRewardedVideoAuctionDelegate.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 13.07.2022.
//

import Foundation
import BidOn


@objc public protocol BNISAuctionDelegate: AnyObject {
    func didStartAuction()
    func didStartAuctionRound(_ round: String, pricefloor: Price)
    func didReceiveAd(_ ad: Ad)
    func didCompleteAuctionRound(_ round: String)
    func didCompleteAuction(_ winner: Ad?)
}
