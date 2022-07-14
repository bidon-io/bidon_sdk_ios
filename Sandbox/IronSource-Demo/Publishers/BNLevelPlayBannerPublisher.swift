//
//  BNISBannerPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator
import SwiftUI
import MobileAdvertising


struct BNLevelPlayBannerPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    enum Event {
        case didLoad(view: UIView, ad: Ad)
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
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNLevelPlayBannerDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNLevelPlayBannerDelegateSubscription<S>: NSObject, Subscription, BNLevelPlayBannerDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNLevelPlayBannerPublisher.Event) {
        guard let subscriber = subscriber else { return }
                    
        demand -= 1
        demand += subscriber.receive(AdEventModel(adType: .banner, event: event))
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func didLoad(_ bannerView: UIView!, with adInfo: Ad!) {
        produce(.didLoad(view: bannerView, ad: adInfo))
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


extension IronSourceDecorator.Proxy {
    var levelPlayBannerPublisher: AnyPublisher<AdEventModel, Never> {
        return BNLevelPlayBannerPublisher { [unowned self] delegate in
            self.setLevelPlayBannerDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}


extension BNLevelPlayBannerPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .didLoad:
            text = Text("ad did load")
        case .didFailToLoadWithError:
            text = Text("ad did fail to load")
        case .didPresentScreen:
            text = Text("ad did present screen")
        case .didDismissScreen:
            text = Text("ad did dismiss screen")
        case .didLeaveApplication:
            text = Text("ad did leave applcation")
        case .didClick:
            text = Text("ad did click")
        }
        
        return Text("(level play)").italic() + Text(" ") + text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didFailToLoadWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "gamecontroller")
    }
    
    var accentColor: Color {
        .red
    }
}
