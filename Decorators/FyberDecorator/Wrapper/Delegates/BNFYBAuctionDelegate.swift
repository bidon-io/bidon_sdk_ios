//
//  BNFYBAuctionDelegate.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import MobileAdvertising


@objc public protocol BNFYBAuctionDelegate: AnyObject {
    func didStartAuction(placement: String)
    func didStartAuctionRound(_ round: String, placement: String, pricefloor: Price)
    func didReceiveAd(_ ad: Ad, placement: String)
    func didCompleteAuctionRound(_ round: String, placement: String)
    func didCompleteAuction(_ winner: Ad?, placement: String)
}
