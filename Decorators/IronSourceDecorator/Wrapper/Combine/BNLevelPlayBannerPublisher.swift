//
//  BNISBannerPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import SwiftUI
import MobileAdvertising


@available(iOS 13, *)
public struct BNLevelPlayBannerPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didLoad(ad: Ad)
        case didFailToLoadWithError(error: Error!)
        case didPresentScreen(ad: Ad)
        case didDismissScreen(ad: Ad)
        case didLeaveApplication(ad: Ad)
        case didClick(ad: Ad)
    }
    
    private let delegate: (BNLevelPlayBannerDelegate) -> ()
        
    init(_ delegate: @escaping (BNLevelPlayBannerDelegate) -> ()) {
        self.delegate = delegate
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNLevelPlayBannerDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate  class BNLevelPlayBannerDelegateSubscription<S>: NSObject, Subscription, BNLevelPlayBannerDelegate
where S : Subscriber, S.Input == BNLevelPlayBannerPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNLevelPlayBannerPublisher.Event) {
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
    
    func didLoad(_ bannerView: UIView!, with adInfo: Ad!) {
        produce(.didLoad(ad: adInfo))
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        produce(.didFailToLoadWithError(error: error))
    }
    
    func didClick(with adInfo: Ad!) {
        produce(.didClick(ad: adInfo))
    }
    
    func didLeaveApplication(with adInfo: Ad!) {
        produce(.didLeaveApplication(ad: adInfo))
    }
    
    func didPresentScreen(with adInfo: Ad!) {
        produce(.didPresentScreen(ad: adInfo))
    }
    
    func didDismissScreen(with adInfo: Ad!) {
        produce(.didDismissScreen(ad: adInfo))
    }
}


@available(iOS 13, *)
public extension IronSourceDecorator.Proxy {
    var levelPlayBannerPublisher: BNLevelPlayBannerPublisher {
        return BNLevelPlayBannerPublisher { [unowned self] delegate in
            self.setLevelPlayBannerDelegate(delegate)
        }
    }
}
