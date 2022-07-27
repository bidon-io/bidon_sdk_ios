//
//  BNFYBBannerPublisher.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import UIKit
import Combine
import BidOn


typealias BNFYBBannerDelegateProvider = (BNFYBBannerDelegate?) -> ()


@available(iOS 13, *)
public struct BNFYBBannerPublisher: Publisher {
    public enum Event {
        case bannerWillRequest(placement: String)
        case bannerDidLoad(banner: BNFYBBannerAdView)
        case bannerDidFailToLoad(placement: String, error: Error)
        case bannerDidShow(banner: BNFYBBannerAdView, impressionData: Ad)
        case bannerDidClick(banner: BNFYBBannerAdView)
        case bannerWillPresentModalView(banner: BNFYBBannerAdView)
        case bannerDidDismissModalView(banner: BNFYBBannerAdView)
        case bannerWillLeaveApplication(banner: BNFYBBannerAdView)
        case bannerDidResizeToFrame(banner: BNFYBBannerAdView, frame: CGRect)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNFYBBannerDelegateProvider
    
    init(_ provider: @escaping BNFYBBannerDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBBannerDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNFYBBannerDelegateSubscription<S>: Subscription, BNFYBBannerDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNFYBBannerPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNFYBBannerPublisher.Event) {
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
    
    func bannerWillRequest(_ placementId: String) {
        trigger(.bannerWillRequest(placement: placementId))
    }
    
    func bannerDidLoad(_ banner: BNFYBBannerAdView) {
        trigger(.bannerDidLoad(banner: banner))
    }
    
    func bannerDidFail(toLoad placementId: String, withError error: Error) {
        trigger(.bannerDidFailToLoad(placement: placementId, error: error))
    }
    
    func bannerDidShow(_ banner: BNFYBBannerAdView, impressionData: Ad) {
        trigger(.bannerDidShow(banner: banner, impressionData: impressionData))
    }
    
    func bannerDidClick(_ banner: BNFYBBannerAdView) {
        trigger(.bannerDidClick(banner: banner))
    }
    
    func bannerWillPresentModalView(_ banner: BNFYBBannerAdView) {
        trigger(.bannerWillPresentModalView(banner: banner))
    }
    
    func bannerDidDismissModalView(_ banner: BNFYBBannerAdView) {
        trigger(.bannerDidDismissModalView(banner: banner))
    }
    
    func bannerWillLeaveApplication(_ banner: BNFYBBannerAdView) {
        trigger(.bannerWillLeaveApplication(banner: banner))
    }
    
    func banner(_ banner: BNFYBBannerAdView, didResizeToFrame frame: CGRect) {
        trigger(.bannerDidResizeToFrame(banner: banner, frame: frame))
    }
}


@available(iOS 13, *)
public extension BNFYBBanner {
    static var publisher: BNFYBBannerPublisher {
        BNFYBBannerPublisher { delegate in
            self.delegate = delegate
        }
    }
}
