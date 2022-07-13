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


@objc final public class BNFYBBannerAdView: AdContainerView {
    internal var ad: Ad?
    internal var provider: AdViewDemandProvider?
    
    private let load: () -> ()
    
    @objc public let options: FYBBannerOptions
    
    internal init(
        options: FYBBannerOptions,
        load: @escaping () -> ()
    ) {
        self.options = options
        self.load = load
        super.init(frame: .zero)
    }
    
    public override func preferredSize() -> CGSize {
        return AdViewFormat.default.preferredSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fetch(_ completion: @escaping (AdView?) -> ()) {
        guard let adView = provider?.adView else { return }
        completion(adView)
    }

    public override func loadAd() {
        load()
    }
}
