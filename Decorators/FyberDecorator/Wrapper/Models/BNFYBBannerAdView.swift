//
//  BNFYBBannerAdView.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import UIKit
import MobileAdvertising
import FairBidSDK


@objc final public class BNFYBBannerAdView: UIView {
    internal let ad: Ad
    internal let provider: AdViewDemandProvider
    
    @objc public let options: FYBBannerOptions
    
    internal init(
        ad: Ad,
        provider: AdViewDemandProvider,
        options: FYBBannerOptions
    ) {
        self.ad = ad
        self.provider = provider
        self.options = options
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        guard let adView = provider.adView else { return }
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adView)
        
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor),
            adView.trailingAnchor.constraint(equalTo: trailingAnchor),
            adView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
}
