//
//  BannerView.swift
//  Sandbox
//
//  Created by Bidon Team on 12.10.2022.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import Bidon


struct RawBannerView: UIViewRepresentable, AdBannerWrapperView {
    typealias UIViewType = BannerView
    
    var format: AdBannerWrapperFormat
    var isAutorefreshing: Bool
    var autorefreshInterval: TimeInterval
    var pricefloor: Price
    var onEvent: AdBannerWrapperViewEvent
    
    init(
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
    
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(frame: .zero)
        
        banner.format = BannerFormat(format)
        banner.rootViewController = UIApplication.shared.bd.topViewcontroller
        banner.loadAd(with: pricefloor)
        banner.delegate = context.coordinator
        
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.format = BannerFormat(format)
        uiView.isAutorefreshing = isAutorefreshing
        uiView.autorefreshInterval = autorefreshInterval
        uiView.loadAd(with: pricefloor)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onEvent: onEvent)
    }
    
    final class Coordinator: BaseAdWrapper {
        private var cancellable: AnyCancellable?
        
        override var adType: AdType { .banner }
        
        init(onEvent: @escaping AdBannerWrapperViewEvent) {
            super.init()
            
            self.cancellable = self.adEventSubject
                .receive(on: RunLoop.main)
                .sink(receiveValue: onEvent)
        }
    }
}


extension RawBannerView.Coordinator: Bidon.AdViewDelegate {
    func adView(_ adView: UIView & Bidon.AdView, willPresentScreen ad: Bidon.Ad) {
        send(
            event: "Bidon will present screen",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adView(_ adView: UIView & Bidon.AdView, didDismissScreen ad: Bidon.Ad) {
        send(
            event: "Bidon will dismiss screen",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adView(_ adView: UIView & Bidon.AdView, willLeaveApplication ad: Bidon.Ad) {
        send(
            event: "Bidon will leave application",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
}

