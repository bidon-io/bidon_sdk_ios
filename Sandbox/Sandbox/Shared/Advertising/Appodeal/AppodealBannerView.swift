//
//  AppodealBannerView.swift
//  Sandbox
//
//  Created by Bidon Team on 20.02.2023.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import Bidon
import Appodeal


struct AppodealBannerView: UIViewRepresentable, AdBannerWrapperView {
    typealias UIViewType = UIView
    
    var format: AdBannerWrapperFormat
    var isAutorefreshing: Bool
    var autorefreshInterval: TimeInterval
    var pricefloor: Price
    var onEvent: AdBannerWrapperViewEvent
    
    @Binding var ad: Bidon.Ad?
    
    init(
        format: AdBannerWrapperFormat,
        isAutorefreshing: Bool,
        autorefreshInterval: TimeInterval,
        pricefloor: Price = 0.1,
        onEvent: @escaping AdBannerWrapperViewEvent,
        ad: Binding<Bidon.Ad?>
    ) {
        self.format = format
        self.isAutorefreshing = isAutorefreshing
        self.autorefreshInterval = autorefreshInterval
        self.onEvent = onEvent
        self.pricefloor = pricefloor
        self._ad = ad
    }
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.load(
            container: uiView,
            format: format,
            isAutorefreshing: isAutorefreshing,
            autorefreshInterval: autorefreshInterval,
            pricefloor: pricefloor
        )
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onEvent: onEvent
        ) {
            self.ad = $0
        }
    }
    
    final class Coordinator: BaseAdWrapper {
        override var adType: AdType { .banner }
        
        private var cancellables = Set<AnyCancellable>()
        
        private weak var container: UIView?
        
        private var format: AdBannerWrapperFormat!
        private var pricefloor: Double!
        private var isAutorefreshing: Bool!
        private var autorefreshInterval: TimeInterval!
        
        private lazy var banners = [Price: UIView]()
        private lazy var cache = [AnyObject]()
        
        init(
            onEvent: @escaping AdBannerWrapperViewEvent,
            onUpdateAd: @escaping (Bidon.Ad?) -> ()
        ) {
            super.init()
            
            adEventSubject
                .receive(on: RunLoop.main)
                .sink(receiveValue: onEvent)
                .store(in: &cancellables)
            
            adSubject
                .receive(on: RunLoop.main)
                .sink(receiveValue: onUpdateAd)
                .store(in: &cancellables)
        }
        
        func load(
            container: UIView,
            format: AdBannerWrapperFormat,
            isAutorefreshing: Bool,
            autorefreshInterval: TimeInterval,
            pricefloor: Price
        ) {
            self.container = container
            self.format = format
            self.isAutorefreshing = isAutorefreshing
            self.autorefreshInterval = autorefreshInterval
            self.pricefloor = pricefloor
            
            performMediation()
        }
        
        func performMediation() {
            guard let controller = UIApplication.shared.bd.topViewcontroller
            else { fatalError("Unable to find root view controller for banner") }
            
            let banner = APDBannerView(
                size: format.preferredSize,
                rootViewController: controller,
                sdk: APDSdk.shared(),
                delegate: self,
                autocache: false
            )
            
            banner.usesSmartSizing = format == .adaptive
            banner.loadAd()
            
            cache.append(banner)
        }
        
        func performPostBid() {
            let pricefloor = max(pricefloor, (banners.keys.max() ?? 0))
            
            let banner = Bidon.BannerView(frame: .zero)
            
            banner[extrasKey: "appodeal_key"] = true
            
            banner.format = Bidon.BannerFormat(format)
            banner.isAutorefreshing = false
            banner.rootViewController = UIApplication.shared.bd.topViewcontroller
            banner.delegate = self
            banner.loadAd(with: pricefloor)
            
            cache.append(banner)
        }
        
        func layoutBannerIfNeeded() {
            defer { cache.removeAll() }
            guard
                let view = banners.sorted(by: { $0.key > $1.key }).first?.value,
                let container = container
            else { return }
            
            container.subviews.forEach { $0.removeFromSuperview() }
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(equalTo: container.leftAnchor),
                view.rightAnchor.constraint(equalTo: container.rightAnchor),
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
    }
}


extension AppodealBannerView.Coordinator: APDBannerViewDelegate {
    func bannerViewDidLoadAd(_ bannerView: APDBannerView, isPrecache precache: Bool) {
        send(
            event: "Appodeal did load \(precache ? "precache" : "") ad",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
        
        cache = cache.filter { $0 !== bannerView }
        banners[bannerView.predictedEcpm] = bannerView
        
        performPostBid()
    }
    
    func bannerView(_ bannerView: APDBannerView, didFailToLoadAdWithError error: Error) {
        send(
            event: "Appodeal did fail to load ad",
            detail: "",
            bage: "star.fill",
            color: .red
        )
        
        cache = cache.filter { $0 !== bannerView }
        
        performPostBid()
    }
    
    func bannerViewExpired(_ bannerView: APDBannerView) {
        send(
            event: "Appodeal did expire",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
    }
    
    func bannerViewDidShow(_ bannerView: APDBannerView) {
        send(
            event: "Appodeal did show",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
    }
    
    func bannerViewDidInteract(_ bannerView: APDBannerView) {
        send(
            event: "Appodeal did click",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
    }
    
    func bannerView(_ bannerView: APDBannerView, didFailToPresentWithError error: Error) {
        send(
            event: "Appodeal did fail to present ad",
            detail: "",
            bage: "star.fill",
            color: .red
        )
    }
}


extension AppodealBannerView.Coordinator: Bidon.AdViewDelegate {
    override func adObject(_ adObject: AdObject, didLoadAd ad: Ad) {
        super.adObject(adObject, didLoadAd: ad)
        cache = cache.filter { $0 !== adObject }
        banners[ad.eCPM] = adObject as? UIView
        
        layoutBannerIfNeeded()
    }
    
    override func adObject(_ adObject: AdObject, didFailToLoadAd error: Error) {
        super.adObject(adObject, didFailToLoadAd: error)
        cache = cache.filter { $0 !== adObject }
        
        layoutBannerIfNeeded()
    }
    
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
