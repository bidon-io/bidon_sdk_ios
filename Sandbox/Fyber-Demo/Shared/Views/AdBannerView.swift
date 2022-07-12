//
//  BannerView.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import SwiftUI
import FyberDecorator
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
        options.presentingViewController = UIApplication.shared.topViewContoller
        
        BNFYBBanner.show(
            in: view,
            position: .top,
            options: options
        )
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
