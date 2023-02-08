//
//  InterstitialDelegate.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation

@objc(BDNAdObject)
public protocol AdObject {
    var isReady: Bool { get }
}


@objc(BDNAdObjectDelegate)
public protocol AdObjectDelegate: AnyObject {
    func adObject(
        _ adObject: AdObject,
        didLoadAd ad: Ad
    )
    
    func adObject(
        _ adObject: AdObject,
        didFailToLoadAd error: Error
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didRecordImpression ad: Ad
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didRecordClick ad: Ad
    )
    
    @objc optional
    func adObjectDidStartAuction(
        _ adObject: AdObject
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didStartAuctionRound auctionRound: String,
        pricefloor: Price
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didReceiveBid ad: Ad
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didCompleteAuctionRound auctionRound: String
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didCompleteAuction winner: Ad?
    )
    
    @objc optional
    func adObject(
        _ adObject: AdObject,
        didPayRevenue ad: Ad
    )
}
