//
//  ISInterstitialPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import SwiftUI


@available(iOS 13, *)
public struct ISInterstitialPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didLoad
        case didFailToLoadWithError(error: Error!)
        case didFailToShowWithError(error: Error!)
        case didOpen
        case didShow
        case didClose
        case didStart
        case didClick
    }
    
    private let delegate: (ISInterstitialDelegate) -> ()
        
    init(_ delegate: @escaping (ISInterstitialDelegate) -> ()) {
        self.delegate = delegate
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ISInterstitialDelegateSubscribtion(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}

@available(iOS 13, *)
final fileprivate class ISInterstitialDelegateSubscribtion<S>: NSObject, Subscription, ISInterstitialDelegate
where S : Subscriber, S.Input == ISInterstitialPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: ISInterstitialPublisher.Event) {
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
    
    func interstitialDidLoad() {
        produce(.didLoad)
    }
    
    func interstitialDidFailToLoadWithError(_ error: Error!) {
        produce(.didFailToLoadWithError(error: error))
    }
    
    func interstitialDidOpen() {
        produce(.didOpen)
    }
    
    func interstitialDidClose() {
        produce(.didClose)
    }
    
    func interstitialDidShow() {
        produce(.didShow)
    }
    
    func interstitialDidFailToShowWithError(_ error: Error!) {
        produce(.didFailToShowWithError(error: error))
    }
    
    func didClickInterstitial() {
        produce(.didClose)
    }
}


@available(iOS 13, *)
public extension IronSourceDecorator.Proxy {
    var interstitialPublisher: ISInterstitialPublisher {
        return ISInterstitialPublisher { [unowned self] delegate in
            self.setInterstitialDelegate(delegate)
        }
    }
}
