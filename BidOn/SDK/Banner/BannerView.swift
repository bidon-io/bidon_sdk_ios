//
//  BannerView.swift
//  BidOn
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import SwiftUI


@available(iOS 13, *)
public struct BannerView: UIViewRepresentable {
    public typealias UIViewType = Banner
       
    public var format: AdViewFormat
    public var isAutorefreshing: Bool
    public var autorefreshInterval: TimeInterval
    
    public init(
        format: AdViewFormat = .banner,
        isAutorefreshing: Bool = true,
        autorefreshInterval: TimeInterval = 15
    ) {
        self.format = format
        self.isAutorefreshing = isAutorefreshing
        self.autorefreshInterval = autorefreshInterval
    }
    
    public func makeUIView(context: Context) -> Banner {
        let banner = Banner(frame: .zero)
        banner.format = format
        banner.loadAd()
        return banner
    }
    
    public func updateUIView(_ uiView: Banner, context: Context) {
        uiView.format = format
        uiView.isAutorefreshing = isAutorefreshing
        uiView.autorefreshInterval = autorefreshInterval
    }
}
