//
//  BNFYBRewardedPublisher.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import Combine
import FyberDecorator
import FairBidSDK
import MobileAdvertising


struct BNFYBRewardedPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    private let delegate: (BNFYBRewardedDelegate?) -> ()
        
    init(_ delegate: @escaping (BNFYBRewardedDelegate?) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBRewardedDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNFYBRewardedDelegateSubscription<S>: NSObject, Subscription, BNFYBRewardedDelegate
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
            AdEventModel(adType: .rewardedVideo, event: event)
        )
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func rewardedWillRequest(_ placementName: String) {
        produce(.willRequest(placement: placementName))
    }
    
    func rewardedIsAvailable(_ placementName: String) {
        produce(.isAvailable(placement: placementName))
    }
    
    func rewardedIsUnavailable(_ placementName: String) {
        produce(.isUnavailable(placement: placementName))
    }
    
    func rewardedDidShow(_ placementName: String, impressionData: Ad) {
        produce(.didShow(placement: placementName, impression: impressionData))
    }
    
    func rewardedDidFail(toShow placementName: String, withError error: Error, impressionData: Ad) {
        produce(.didFailToShow(placement: placementName, impression: impressionData, error: error))
    }
    
    func rewardedDidClick(_ placementName: String) {
        produce(.didClick(placement: placementName))
    }
    
    func rewardedDidDismiss(_ placementName: String) {
        produce(.didDismiss(placement: placementName))
    }
    
    func rewardedDidComplete(_ placementName: String, userRewarded: Bool) {
        produce(.didComplete(placement: placementName, isRewarded: userRewarded))
    }
}


extension BNFYBRewarded {
    static func publisher() -> AnyPublisher<AdEventModel, Never> {
        return BNFYBRewardedPublisher { delegate in
            self.delegate = delegate
        }
        .eraseToAnyPublisher()
    }
}
