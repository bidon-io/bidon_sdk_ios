//
//  AdBannerView.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import SwiftUI
import IronSource
import BidOnDecoratorIronSource


struct AdBannerView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    var size: ISBannerSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        context.coordinator.container = view
        context.coordinator.loadAd(size)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.dismant()
    }
    
    final class Coordinator: NSObject, BNISBannerDelegate {
        weak var container: UIView?
        weak var adView: UIView?
        
        override init() {
            super.init()
            IronSource.bn.setBannerDelegate(self)
        }
        
        func loadAd(_ size: ISBannerSize) {
            let controller = UIApplication.shared.bn.topViewContoller!
            IronSource.bn.loadBanner(with: controller, size: size)
        }
        
        func dismant() {
            adView.map { IronSource.bn.destroyBanner($0) }
        }
        
        func bannerDidLoad(_ bannerView: UIView) {
            defer { self.adView = bannerView }
            guard let container = container else { return }
            
            container.subviews.forEach { $0.removeFromSuperview() }
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(bannerView)
            
            NSLayoutConstraint.activate([
                bannerView.topAnchor.constraint(equalTo: container.topAnchor),
                bannerView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                bannerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                bannerView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        }
        
        func bannerDidFailToLoadWithError(_ error: Error) {}
        
        func didClickBanner() {}
        
        func bannerWillPresentScreen() {}
        
        func bannerDidDismissScreen() {}
        
        func bannerWillLeaveApplication() {}
    }
}
