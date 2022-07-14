//
//  BNFYBInterstitialPublisher.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import Combine
import FyberDecorator
import FairBidSDK
import MobileAdvertising


struct BNFYBInterstitialPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    private let delegate: (BNFYBInterstitialDelegate?) -> ()
        
    init(_ delegate: @escaping (BNFYBInterstitialDelegate?) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBInterstitialDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNFYBInterstitialDelegateSubscription<S>: NSObject, Subscription, BNFYBInterstitialDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: AdEvent) {
        guard let subscriber = subscriber else { return }
                    
        demand -= 1
        demand += subscriber.receive(
            AdEventModel(adType: .interstitial, event: event)
        )
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func interstitialWillRequest(_ placementId: String) {
        produce(.willRequest(placement: placementId))
    }
    
    func interstitialIsAvailable(_ placementId: String) {
        produce(.isAvailable(placement: placementId))
    }
    
    func interstitialIsUnavailable(_ placementId: String) {
        produce(.isUnavailable(placement: placementId))
    }
    
    func interstitialDidShow(_ placementId: String, impressionData: Ad) {
        produce(.didShow(placement: placementId, impression: impressionData))
    }
    
    func interstitialDidFail(toShow placementId: String, withError error: Error, impressionData: Ad) {
        produce(.didFailToShow(placement: placementId, impression: impressionData, error: error))
    }
    
    func interstitialDidClick(_ placementId: String) {
        produce(.didClick(placement: placementId))
    }
    
    func interstitialDidDismiss(_ placementId: String) {
        produce(.didDismiss(placement: placementId))
    }
}


extension BNFYBInterstitial {
    static func publisher() -> AnyPublisher<AdEventModel, Never> {
        return BNFYBInterstitialPublisher { delegate in
            self.delegate = delegate
        }
        .eraseToAnyPublisher()
    }
}
