//
//  GoogleMobileAdsParameters.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import MobileAdvertising



public struct GoogleMobileAdsParameters: Codable {
    var lineItems: LineItems
    
    public init(
        interstitial: [LineItem]? = nil,
        rewardedAd: [LineItem]? = nil,
        banner: [LineItem]? = nil
    ) {
        lineItems = LineItems(
            interstitial: interstitial,
            rewardedAd: rewardedAd,
            banner: banner
        )
    }
}

public struct LineItems: Codable {
    var interstitial: [LineItem]?
    var rewardedAd: [LineItem]?
    var banner: [LineItem]?
}

public struct LineItem: Codable {
    var pricefloor: Price
    var adUnitId: String
    
    public init(
        _ pricefloor: Price,
        adUnitId: String
    ) {
        self.pricefloor = pricefloor
        self.adUnitId = adUnitId
    }
}


internal extension Array where Element == LineItem {
    func item(for pricefloor: Price) -> LineItem? {
        guard !pricefloor.isUnknown else { return first }
        return sorted { $0.pricefloor < $1.pricefloor }
            .filter { $0.pricefloor > pricefloor }
            .first
    }
}
