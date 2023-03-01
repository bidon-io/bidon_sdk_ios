//
//  BaseAdWrapper.swift
//  Sandbox
//
//  Created by Bidon Team on 20.02.2023.
//

import Foundation
import Combine
import Bidon


class BaseAdWrapper: NSObject, AdWrapper {
    final let adEventSubject = PassthroughSubject<AdEventModel, Never>()
    
    open var adType: AdType { fatalError("Undefined ad type") }
}


extension BaseAdWrapper: Bidon.AdObjectDelegate {
    func adObject(_ adObject: Bidon.AdObject, didLoadAd ad: Bidon.Ad) {
        send(
            event: "Bidon did load ad",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adObject(_ adObject: Bidon.AdObject, didFailToLoadAd error: Error) {
        send(
            event: "Bidon did fail to load ad",
            detail: error.localizedDescription,
            bage: "star.fill",
            color: .red
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didRecordImpression ad: Ad
    ) {
        send(
            event: "Bidon did record impression",
            detail: ad.text,
            bage: "flag.fill",
            color: .accentColor
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didRecordClick ad: Ad
    ) {
        send(
            event: "Bidon did record click",
            detail: ad.text,
            bage: "flag.fill",
            color: .accentColor
        )
    }
    
    func adObjectDidStartAuction(
        _ adObject: AdObject
    ) {
        send(
            event: "Bidon did start auction",
            detail: "",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didStartAuctionRound auctionRound: String,
        pricefloor: Price
    ) {
        send(
            event: "Bidon did start auction round \(auctionRound)",
            detail: "Pricefloor: \(pricefloor)",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didReceiveBid ad: Ad
    ) {
        send(
            event: "Bidon did receive bid",
            detail: ad.text,
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didCompleteAuctionRound auctionRound: String
    ) {
        send(
            event: "Bidon did complete auction round \(auctionRound)",
            detail: "",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didCompleteAuction winner: Ad?
    ) {
        send(
            event: "Bidon did complete auction",
            detail: winner.map { "Winner ad is \($0.text)" } ?? "No winner",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didPay revenue: AdRevenue,
        ad: Ad
    ) {
        send(
            event: "Bidon did pay revenue \(revenue.revenue.pretty)",
            detail: ad.text,
            bage: "cart.fill",
            color: .primary
        )
    }
}
