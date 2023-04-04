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
    func adObject(
        _ adObject: AdObject,
        didPay revenue: AdRevenue,
        ad: Ad
    )
}
