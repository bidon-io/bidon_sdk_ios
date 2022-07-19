//
//  BNLevelPlayInterstitialPublishers.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import MobileAdvertising
import SwiftUI


@available(iOS 13, *)
public struct BNLevelPlayInterstitialPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didLoad(adInfo: Ad!)
        case didFailToLoadWithError(error: Error!)
        case didFailToShowWithError(error: Error!, adInfo: Ad!)
        case didShow(adInfo: Ad!)
        case didOpen(adInfo: Ad!)
        case didClick(adInfo: Ad!)
        case didClose(adInfo: Ad!)
    }
    
    private let delegate: (BNLevelPlayInterstitialDelegate) -> ()
    
    init(_ delegate: @escaping (BNLevelPlayInterstitialDelegate) -> ()) {
        self.delegate = delegate
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNLevelPlayInterstitialDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class BNLevelPlayInterstitialDelegateSubscription<S>: NSObject, Subscription, BNLevelPlayInterstitialDelegate
where S : Subscriber, S.Input == BNLevelPlayInterstitialPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNLevelPlayInterstitialPublisher.Event) {
        guard let subscriber = subscriber else { return }
        
        demand -= 1
        demand += subscriber.receive(event)
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func didLoad(with adInfo: Ad!) {
        produce(.didLoad(adInfo: adInfo))
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        produce(.didFailToLoadWithError(error: error))
    }
    
    func didShow(with adInfo: Ad!) {
        produce(.didShow(adInfo: adInfo))
    }
    
    func didOpen(with adInfo: Ad!) {
        produce(.didOpen(adInfo: adInfo))
    }
    
    func didClick(with adInfo: Ad!) {
        produce(.didClick(adInfo: adInfo))
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: Ad!) {
        produce(.didFailToShowWithError(error: error, adInfo: adInfo))
    }
    
    func didClose(with adInfo: Ad!) {
        produce(.didClose(adInfo: adInfo))
    }
}


@available(iOS 13, *)
public extension IronSourceDecorator.BNISProxy {
    var levelPlayInterstitialPublisher: BNLevelPlayInterstitialPublisher {
        return BNLevelPlayInterstitialPublisher { [unowned self] delegate in
            self.setLevelPlayInterstitialDelegate(delegate)
        }
    }
}
