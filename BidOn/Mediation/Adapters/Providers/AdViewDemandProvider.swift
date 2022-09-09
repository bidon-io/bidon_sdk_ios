//
//  AdViewDemandProvider.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import UIKit


public struct AdViewContext {
    public var format: AdViewFormat
    public var size: CGSize
    public var rootViewController: UIViewController?
    
    public init(
        format: AdViewFormat,
        size: CGSize,
        rootViewController: UIViewController?
    ) {
        self.format = format
        self.size = size
        self.rootViewController = rootViewController
    }
    
    public init(
        _ format: AdViewFormat,
        rootViewController: UIViewController? = nil
    ) {
        self = .init(
            format: format,
            size: format.preferredSize,
            rootViewController: rootViewController ?? UIApplication.shared.bd.topViewcontroller
        )
    }
}


@objc public enum AdViewFormat: Int, Codable {
    case banner
    case leaderboard
    case mrec
    case adaptive
    
    public var preferredSize: CGSize {
        switch self {
        case .banner:
            return CGSize(width: 320, height: 50)
        case .leaderboard:
            return CGSize(width: 728, height: 90)
        case .mrec:
            return CGSize(width: 300, height: 250)
        case .adaptive:
            return UIDevice.bd.isPhone ?
            CGSize(width: 320, height: 50) :
            CGSize(width: 728, height: 90)
        }
    }
}


public protocol AdViewContainer: UIView {
    var isAdaptive: Bool { get }
}


public protocol DemandProviderAdViewDelegate: AnyObject {
    func providerWillPresentModalView(_ provider: AdViewDemandProvider, adView: AdViewContainer)
    func providerDidDismissModalView(_ provider: AdViewDemandProvider, adView: AdViewContainer)
    func providerWillLeaveApplication(_ provider: AdViewDemandProvider, adView: AdViewContainer)
}


public protocol AdViewDemandProvider: DemandProvider {
    var adViewDelegate: DemandProviderAdViewDelegate? { get set }
    
    func container(for ad: Ad) -> AdViewContainer? 
}
