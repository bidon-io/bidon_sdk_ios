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


@objc(BDNAdViewFormat)
public enum AdViewFormat: Int, Codable, CustomStringConvertible {
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
    
    public var description: String {
        return stringValue.capitalized
    }
    
    var stringValue: String {
        switch self {
        case .banner: return "banner"
        case .leaderboard: return "leaderboard"
        case .mrec: return "mrec"
        case .adaptive: return "adaptive"
        }
    }
    
    init(_ stringValue: String) throws {
        switch stringValue {
        case "banner": self = .banner
        case "leaderboard": self = .leaderboard
        case "mrec": self = .mrec
        case "adaptive": self = .adaptive
        default: throw SdkError("Unable to create with '\(stringValue)'")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue.uppercased())
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        try self.init(stringValue)
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
