//
//  InterstitialDelegate.swift
//  Bidon
//
//  Created by Bidon Team on 12.08.2022.
//

import Foundation

@objc(BDNAdObject)
public protocol AdObject: ExtrasProvider {
    var isReady: Bool { get }

    @objc(notifyWin)
    func notifyWin()

    @objc(notifyLossWithExternalDemandId:price:)
    func notifyLoss(
        external demandId: String,
        price: Price
    )
}


@objc(BDNAdObjectDelegate)
public protocol AdObjectDelegate: AnyObject {
    func adObject(
        _ adObject: AdObject,
        didLoadAd ad: Ad,
        auctionInfo: AuctionInfo
    )

    func adObject(
        _ adObject: AdObject,
        didFailToLoadAd error: Error,
        auctionInfo: AuctionInfo
    )

    @objc optional
    func adObject(
        _ adObject: AdObject,
        didExpireAd ad: Ad
    )

    @objc optional
    func adObject(
        _ adObject: AdObject,
        didFailToPresentAd error: Error
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
    func adObject(
        _ adObject: AdObject,
        didPay revenue: AdRevenue,
        ad: Ad
    )
}
