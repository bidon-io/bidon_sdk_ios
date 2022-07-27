//
//  BannerView.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import SwiftUI
import BidOnDecoratorFyber
import FairBidSDK


struct AdBannerView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    var placement: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: 320, height: 50)
            )
        )
        
        let options = FYBBannerOptions()
        options.placementId = placement
        options.presentingViewController = UIApplication.shared.bn.topViewContoller
        
        BNFYBBanner.show(
            in: view,
            position: .top,
            options: options
        )
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        uiView
            .subviews
            .compactMap { $0 as? BNFYBBannerAdView }
            .first
            .map { $0.options.placementId }
            .map { BNFYBBanner.destroy($0) }
    }
}
