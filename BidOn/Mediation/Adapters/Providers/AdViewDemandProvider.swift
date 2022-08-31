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
    public var isAdaptive: Bool
    public var rootViewController: UIViewController?
    
    public init(
        format: AdViewFormat,
        size: CGSize,
        isAdaptive: Bool,
        rootViewController: UIViewController?
    ) {
        self.format = format
        self.size = size
        self.isAdaptive = isAdaptive
        self.rootViewController = rootViewController
    }
    
    public init(
        _ format: AdViewFormat,
        isAdaptive: Bool = false,
        rootViewController: UIViewController? = nil
    ) {
        self = .init(
            format: format,
            size: format.preferredSize,
            isAdaptive: isAdaptive,
            rootViewController: rootViewController ?? UIApplication.shared.bd.topViewcontroller
        )
    }
}


@objc public enum AdViewFormat: Int {
    case banner
    case leaderboard
    case mrec
    
    public var preferredSize: CGSize {
        switch self {
        case .banner:
            return CGSize(width: 320, height: 50)
        case .leaderboard:
            return CGSize(width: 728, height: 90)
        case .mrec:
            return CGSize(width: 300, height: 250)
        }
    }
}


public protocol AdViewContainer: UIView {
    var isAdaptive: Bool { get }
}


public protocol DemandProviderAdViewDelegate: AnyObject {
    func providerWillPresentModalView(_ provider: AdViewDemandProvider)
    func providerDidDismissModalView(_ provider: AdViewDemandProvider)
    func providerWillLeaveApplication(_ provider: AdViewDemandProvider)
}


public protocol AdViewDemandProvider: DemandProvider {
    var adViewDelegate: DemandProviderAdViewDelegate? { get set }
    
    func container(for ad: Ad) -> AdViewContainer? 
}