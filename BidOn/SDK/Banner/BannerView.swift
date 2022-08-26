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
       
    public init() {
        
    }
    
    public func makeUIView(context: Context) -> Banner {
        let banner = Banner(frame: .zero)
        banner.loadAd()
        return banner
    }
    
    public func updateUIView(_ uiView: Banner, context: Context) {
        
    }
}
