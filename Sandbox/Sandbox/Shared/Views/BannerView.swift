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
public struct BannerView: UIViewRepresentable {
    public typealias Event = (BannerPublisher.Event) -> ()
    public typealias UIViewType = Banner
    
    public var format: AdViewFormat
    public var isAutorefreshing: Bool
    public var autorefreshInterval: TimeInterval
    public var pricefloor: Price
    public var onEvent: Event?
    
    public init(
        format: AdViewFormat = .adaptive,
        isAutorefreshing: Bool = true,
        autorefreshInterval: TimeInterval = 15,
        pricefloor: Price = 0.1,
        onEvent: Event? = nil
    ) {
        self.format = format
        self.isAutorefreshing = isAutorefreshing
        self.autorefreshInterval = autorefreshInterval
        self.onEvent = onEvent
        self.pricefloor = pricefloor
    }
    
    public func makeUIView(context: Context) -> Banner {
        let banner = Banner(frame: .zero)
        
        context.coordinator.subscribe(banner)
        banner.format = format
        banner.loadAd(with: pricefloor)
        
        return banner
    }
    
    public func updateUIView(_ uiView: Banner, context: Context) {
        uiView.format = format
        uiView.isAutorefreshing = isAutorefreshing
        uiView.autorefreshInterval = autorefreshInterval
        uiView.loadAd(with: pricefloor)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(onEvent: onEvent)
    }
    
    final public class Coordinator {
        private var cancellable: AnyCancellable?
        private let onEvent: Event?
        
        init(onEvent: Event?) {
            self.onEvent = onEvent
        }
        
        fileprivate func subscribe(_ banner: Banner) {
            cancellable = banner
                .publisher
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] event in
                    self.onEvent?(event)
                }
        }
    }
}
