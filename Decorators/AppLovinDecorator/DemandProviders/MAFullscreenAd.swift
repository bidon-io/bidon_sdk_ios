//
//  MAFullscreenAd.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import AppLovinSDK


struct FullscreenAdDisplayArguments {
    var placement: String?
    var customData: String?
}


internal protocol MAFullscreenAd: AnyObject {
    static func ad(_ adUnitIdentifier: String, sdk: ALSdk?) -> Self

    var adDelegate: MAAdDelegate? { get set }
    var rewardDelegate: MARewardedAdDelegate? { get set }
    
    func load()
    
    func show(
        _ args: FullscreenAdDisplayArguments?,
        from viewController: UIViewController
    )
}


extension MAInterstitialAd: MAFullscreenAd {
    static func ad(_ adUnitIdentifier: String, sdk: ALSdk?) -> Self {
        if let sdk = sdk {
            return self.init(adUnitIdentifier: adUnitIdentifier, sdk: sdk)
        } else {
            return self.init(adUnitIdentifier: adUnitIdentifier)
        }
    }
    
    var adDelegate: MAAdDelegate? {
        get { delegate }
        set { delegate = newValue }
    }
    
    var rewardDelegate: MARewardedAdDelegate? {
        get { return nil }
        set { }
    }
    
    func show(
        _ args: FullscreenAdDisplayArguments?,
        from viewController: UIViewController
    ) {
        show(
            forPlacement: args?.placement,
            customData: args?.customData,
            viewController: viewController
        )
    }
}


extension MARewardedAd: MAFullscreenAd {
    static func ad(_ adUnitIdentifier: String, sdk: ALSdk?) -> Self {
        if let sdk = sdk {
            return self.shared(withAdUnitIdentifier: adUnitIdentifier, sdk: sdk)
        } else {
            return self.shared(withAdUnitIdentifier: adUnitIdentifier)
        }
    }
    
    var adDelegate: MAAdDelegate? {
        get { nil }
        set { }
    }
    
    var rewardDelegate: MARewardedAdDelegate? {
        get { delegate }
        set { delegate = newValue }
    }
    
    func show(
        _ args: FullscreenAdDisplayArguments?,
        from viewController: UIViewController
    ) {
        show(
            forPlacement: args?.placement,
            customData: args?.customData,
            viewController: viewController
        )
    }
}
