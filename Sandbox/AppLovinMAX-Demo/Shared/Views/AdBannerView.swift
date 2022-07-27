//
//  AdBannerView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import SwiftUI
import Combine
import AppLovinSDK
import BidOnDecoratorAppLovinMax
import BidOn


struct AdBannerView: UIViewRepresentable {
    typealias UIViewType = BNMAAdView
    
    @Binding var isAutoRefresh: Bool
    @Binding var autorefreshInterval: TimeInterval
    @Binding var isAdaptive: Bool

    var adUnitIdentifier: String
    var adFormat: MAAdFormat
    var sdk: ALSdk
    var event: (AdEventModel) -> ()
    
    func makeUIView(context: Context) -> BNMAAdView {
        let view = BNMAAdView(
            adUnitIdentifier: adUnitIdentifier,
            adFormat: adFormat,
            sdk: sdk
        )

        context.coordinator.subscribe(view)
        
        view.resolver = resolver
        view.loadAd()
        
        return view
    }
    
    func updateUIView(_ uiView: BNMAAdView, context: Context) {
        isAutoRefresh ? uiView.startAutoRefresh() : uiView.stopAutoRefresh()
        uiView.autorefreshInterval = autorefreshInterval
        uiView.setExtraParameterForKey("adaptive_banner", value: isAdaptive ? "true" : "false")
    }
    
    static func dismantleUIView(_ uiView: BNMAAdView, coordinator: Coordinator) {
        coordinator.unsubscribe()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(event: event)
    }
    
    final class Coordinator {
        private var cancellables = Set<AnyCancellable>()
        
        let event: (AdEventModel) -> ()
        
        init(event: @escaping (AdEventModel) -> ()) {
            self.event = event
        }
        
        func subscribe(_ view: BNMAAdView) {
            let publisher: AnyPublisher<AdEventModel, Never> = Publishers.MergeMany([
                view
                    .publisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                view
                    .auctionPublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                view
                    .adReviewPublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                view
                    .revenuePublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher()
            ]).eraseToAnyPublisher()
            
            publisher.receive(on: DispatchQueue.main).sink { [unowned self] in
                self.event($0)
            }
            .store(in: &cancellables)
        }
        
        func unsubscribe() {
            cancellables.removeAll()
        }
    }
}
