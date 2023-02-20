//
//  BannerView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 12.10.2022.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import BidOn


@available(iOS 13, *)
struct RawBannerView: UIViewRepresentable, AdBannerWrapperView {
    typealias UIViewType = BannerView
    
    var format: AdBannerWrapperFormat
    var isAutorefreshing: Bool
    var autorefreshInterval: TimeInterval
    var pricefloor: Price
    var onEvent: AdBannerWrapperViewEvent
    
    public init(
        format: AdBannerWrapperFormat,
        isAutorefreshing: Bool,
        autorefreshInterval: TimeInterval,
        pricefloor: Price = 0.1,
        onEvent: @escaping AdBannerWrapperViewEvent
    ) {
        self.format = format
        self.isAutorefreshing = isAutorefreshing
        self.autorefreshInterval = autorefreshInterval
        self.onEvent = onEvent
        self.pricefloor = pricefloor
    }
    
    public func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(frame: .zero)
        
        banner.format = BannerFormat(format)
        banner.loadAd(with: pricefloor)
        banner.delegate = context.coordinator
        
        return banner
    }
    
    public func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.format = BannerFormat(format)
        uiView.isAutorefreshing = isAutorefreshing
        uiView.autorefreshInterval = autorefreshInterval
        uiView.loadAd(with: pricefloor)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(onEvent: onEvent)
    }
    
    final public class Coordinator: BaseAdWrapper {
        private var cancellable: AnyCancellable?
        
        init(onEvent: @escaping AdBannerWrapperViewEvent) {
            super.init()
            
            self.cancellable = self.adEventSubject
                .receive(on: RunLoop.main)
                .sink(receiveValue: onEvent)
        }
    }
}


extension RawBannerView.Coordinator: BidOn.AdViewDelegate {
    func adView(_ adView: UIView & BidOn.AdView, willPresentScreen ad: BidOn.Ad) {
        send(
            event: "BidOn will present screen",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adView(_ adView: UIView & BidOn.AdView, didDismissScreen ad: BidOn.Ad) {
        send(
            event: "BidOn will dismiss screen",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adView(_ adView: UIView & BidOn.AdView, willLeaveApplication ad: BidOn.Ad) {
        send(
            event: "BidOn will leave application",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
}

