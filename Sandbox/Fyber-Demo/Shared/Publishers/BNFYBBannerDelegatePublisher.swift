//
//  BNFYBBannerDelegatePublisher.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import Combine
import FyberDecorator
import FairBidSDK
import MobileAdvertising


struct BNFYBBannerDelegatePublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    private let delegate: (BNFYBBannerDelegate?) -> ()
        
    init(_ delegate: @escaping (BNFYBBannerDelegate?) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBBannerDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNFYBBannerDelegateSubscription<S>: NSObject, Subscription, BNFYBBannerDelegate
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
            AdEventModel(adType: .banner, event: event)
        )
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func bannerDidLoad(_ banner: BNFYBBannerAdView) {
        produce(.didLoad(placement: banner.options.placementId))
    }
    
    func bannerDidFail(toLoad placementId: String, withError error: Error) {
        produce(.didFailToLoad(placement: placementId, error: error))

    }
    
    func bannerDidShow(_ banner: BNFYBBannerAdView, impressionData: Ad) {
        produce(.didShow(placement: banner.options.placementId, impression: impressionData))
    }
    
    func bannerDidClick(_ banner: BNFYBBannerAdView) {
        produce(.didClick(placement: banner.options.placementId))
    }
    
    func bannerWillPresentModalView(_ banner: BNFYBBannerAdView) {
        produce(.willPresentModalView(placement: banner.options.placementId))
    }
    
    func bannerDidDismissModalView(_ banner: BNFYBBannerAdView) {
        produce(.didDimissModalView(placement: banner.options.placementId))
    }
    
    func bannerWillLeaveApplication(_ banner: BNFYBBannerAdView) {
        produce(.willLeaveApplication(placement: banner.options.placementId))
    }
    
    func banner(_ banner: BNFYBBannerAdView, didResizeToFrame frame: CGRect) {
        produce(.didResize(placement: banner.options.placementId, frame: frame))
    }
    
    func bannerWillRequest(_ placementId: String) {
        produce(.willRequest(placement: placementId))
    }
}


extension BNFYBBanner {
    static func publisher() -> AnyPublisher<AdEventModel, Never> {
        return BNFYBBannerDelegatePublisher { delegate in
            self.delegate = delegate
        }
        .eraseToAnyPublisher()
    }
}
