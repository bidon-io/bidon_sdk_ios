//
//  BNISAuctionPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator
import MobileAdvertising
import SwiftUI


struct BNISAuctionPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    enum Event {
        case didStartAuction
        case didStartAuctionRound(round: String, pricefloor: Price)
        case didReceiveAd(ad: Ad)
        case didCompleteAuctionRound(round: String)
        case didCompleteAuction(ad: Ad?)
    }
    
    private let delegate: (BNISAuctionDelegate) -> ()
    private let adType: AdType
    
    init(adType: AdType, _ delegate: @escaping (BNISAuctionDelegate) -> ()) {
        self.adType = adType
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNISAuctionDelegateSubscription(
            subscriber: subscriber,
            adType: adType
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNISAuctionDelegateSubscription<S>: NSObject, Subscription, BNISAuctionDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    private let adType: AdType
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S, adType: AdType) {
        self.subscriber = subscriber
        self.adType = adType
        super.init()
    }
    
    func produce(_ event: BNISAuctionPublisher.Event) {
        guard let subscriber = subscriber else { return }
        
        demand -= 1
        demand += subscriber.receive(AdEventModel(adType: adType, event: event))
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func didStartAuction() {
        produce(.didStartAuction)
    }
    
    func didStartAuctionRound(_ round: String, pricefloor: Price) {
        produce(.didStartAuctionRound(round: round, pricefloor: pricefloor))
    }
    
    func didReceiveAd(_ ad: Ad) {
        produce(.didReceiveAd(ad: ad))
    }
    
    func didCompleteAuctionRound(_ round: String) {
        produce(.didCompleteAuctionRound(round: round))
    }
    
    func didCompleteAuction(_ winner: Ad?) {
        produce(.didCompleteAuction(ad: winner))
    }
}


extension IronSourceDecorator.Proxy {
    var auctionInterstitialPublisher: AnyPublisher<AdEventModel, Never> {
        return BNISAuctionPublisher(adType: .interstitial) { [unowned self] delegate in
            self.setAuctionInterstitialDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
    
    var auctionRewardedVideoPublisher: AnyPublisher<AdEventModel, Never> {
        return BNISAuctionPublisher(adType: .rewardedVideo) { [unowned self] delegate in
            self.setAuctionRewardedVideoDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
    
    var auctionBannerPublisher: AnyPublisher<AdEventModel, Never> {
        return BNISAuctionPublisher(adType: .banner) { [unowned self] delegate in
            self.setAuctionBannerDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}


extension BNISAuctionPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .didStartAuction:
            text = Text("ad did start auction")
        case .didStartAuctionRound(let round, _):
            text = Text("ad did start auction round ") + Text("\"\(round)\"").bold()
        case .didReceiveAd:
            text = Text("ad did receive ad")
        case .didCompleteAuctionRound(let round):
            text = Text("ad did complete auction round ") + Text("\"\(round)\"").bold()
        case .didCompleteAuction:
            text = Text("ad did complete auction")
        }
        
        return text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didStartAuctionRound(_, let pricefloor):
            text = "Pricefloor: \(pricefloor.pretty)"
        case .didReceiveAd(let ad):
            text = "Ad: " + ad.text
        case .didCompleteAuction(let ad):
            text = ad.map { "Winner: " + $0.text } ?? "No winner"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "bolt")
    }
    
    var accentColor: Color {
        .orange
    }
}
