//
//  BaseAdWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 20.02.2023.
//

import Foundation
import Combine
import BidOn


class BaseAdWrapper: NSObject, AdWrapper {
    final let adEventSubject = PassthroughSubject<AdEventModel, Never>()
    
    open var adType: AdType { fatalError("Undefined ad type") }
}


extension BaseAdWrapper: BidOn.AdObjectDelegate {
    func adObject(_ adObject: BidOn.AdObject, didLoadAd ad: BidOn.Ad) {
        send(
            event: "BidOn did load ad",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adObject(_ adObject: BidOn.AdObject, didFailToLoadAd error: Error) {
        send(
            event: "BidOn did fail to load ad",
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
            event: "BidOn did record impression",
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
            event: "BidOn did record click",
            detail: ad.text,
            bage: "flag.fill",
            color: .accentColor
        )
    }
    
    func adObjectDidStartAuction(
        _ adObject: AdObject
    ) {
        send(
            event: "BidOn did start auction",
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
            event: "BidOn did start auction round \(auctionRound)",
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
            event: "BidOn did receive bid",
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
            event: "BidOn did complete auction round \(auctionRound)",
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
            event: "BidOn did complete auction",
            detail: winner.map { "Winner ad is \($0.text)" } ?? "No winner",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didPayRevenue ad: Ad
    ) {
        send(
            event: "BidOn did pay revenue",
            detail: ad.text,
            bage: "cart.fill",
            color: .primary
        )
    }
}
