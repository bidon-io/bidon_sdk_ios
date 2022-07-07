//
//  InterstitialPublisher.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import Combine
import MobileAdvertising
import AppLovinDecorator
import AppLovinSDK


extension BNMAInterstitialAd {
    enum Event {
        case didStartAuction
        case didStartAuctionRound(id: String, pricefloor: Price)
        case didCompleteAuctionRound(id: String)
        case didCompleteAuction(ad: Ad?)
        case didReceive(ad: Ad)
        case didLoad(ad: Ad)
        case didFail(id: String, error: Error)
        case didDisplay(ad: Ad)
        case didHide(ad: Ad)
        case didClick(ad: Ad)
        case didDisplayFail(ad: Ad, error: Error)
        case didPay(ad: Ad)
        case didGenerateCreativeId(id: String, ad: Ad)
    }
    
    struct EventPublisher: Publisher {
        typealias Output = Event
        typealias Failure = Never
        
        let interstitial: BNMAInterstitialAd
        
        init(interstitial: BNMAInterstitialAd) {
            self.interstitial = interstitial
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(
                subscriber: subscriber,
                interstitial: interstitial
            )
            
            interstitial.delegate = subscription
            interstitial.revenueDelegate = subscription
            interstitial.adReviewDelegate = subscription
            interstitial.auctionDelegate = subscription
            
            subscriber.receive(subscription: subscription)
        }
    }
}


extension BNMAInterstitialAd.EventPublisher {
    final fileprivate class Subscription<S>: NSObject, BNMAAdDelegate, BNMAAdRevenueDelegate, BNMAAdReviewDelegate, BNMAuctionDelegate
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        
        var demand: Subscribers.Demand = .none
        weak var interstitial: BNMAInterstitialAd?
        
        init(
            subscriber: S,
            interstitial: BNMAInterstitialAd
        ) {
            self.subscriber = subscriber
            self.interstitial = interstitial
            
            super.init()
        }
        
        func trigger(event: BNMAInterstitialAd.Event) {
            guard let subscriber = subscriber else { return }
                        
            demand -= 1
            demand += subscriber.receive(event)
        }
        
        func cancel() {
            demand = .none
            subscriber = nil
            interstitial = nil
        }
        
        func didLoad(_ ad: Ad) {
            trigger(event: .didLoad(ad: ad))
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: Error) {
            trigger(event: .didFail(id: adUnitIdentifier, error: error))
        }
        
        func didDisplay(_ ad: Ad) {
            trigger(event: .didDisplay(ad: ad))
        }
        
        func didHide(_ ad: Ad) {
            trigger(event: .didHide(ad: ad))
        }
        
        func didClick(_ ad: Ad) {
            trigger(event: .didClick(ad: ad))
        }
        
        func didFail(toDisplay ad: Ad, withError error: Error) {
            trigger(event: .didDisplayFail(ad: ad, error: error))
        }
        
        func didPayRevenue(for ad: Ad) {
            trigger(event: .didPay(ad: ad))
        }
        
        func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: Ad) {
            trigger(event: .didGenerateCreativeId(id: creativeIdentifier, ad: ad))
        }
        
        func didStartAuction() {
            trigger(event: .didStartAuction)
        }
        
        func didStartAuctionRound(_ round: String, pricefloor: Price) {
            trigger(event: .didStartAuctionRound(id: round, pricefloor: pricefloor))
        }
        
        func didReceiveAd(_ ad: Ad) {
            trigger(event: .didReceive(ad: ad))
        }
        
        func didCompleteAuctionRound(_ round: String) {
            trigger(event: .didCompleteAuctionRound(id: round))
        }
        
        func didCompleteAuction(_ winner: Ad?) {
            trigger(event: .didCompleteAuction(ad: winner))
        }
    }
}


extension BNMAInterstitialAd.EventPublisher.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
}


extension BNMAInterstitialAd {
    var publisher: EventPublisher {
        EventPublisher(interstitial: self)
    }
}
