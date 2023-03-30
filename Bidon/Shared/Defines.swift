//
//  Defines.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 15.06.2022.
//

import Foundation


public enum SdkError: Error, CustomStringConvertible {
    case generic(error: Error)
    case message(String)
    case unknown
    
    case noFill
    case cancelled
    case internalInconsistency
    case invalidPresentationState
    case unableToFindRootViewController
    
    public var description: String {
        switch self {
        case .noFill:
            return "No fill"
        case .internalInconsistency:
            return "Inconsistent state"
        case .unknown:
            return "Unknown"
        case .cancelled:
            return "Request has been cancelled"
        case .invalidPresentationState:
            return "Invalid presentation state"
        case .unableToFindRootViewController:
            return "Unable to find root view controller"
        case .generic(let error):
            return error.localizedDescription
        case .message(let message):
            return message
        }
    }
    
    public init(_ message: String) {
        self = .message(message)
    }
    
    public init(_ error: Error?) {
        if let error = error as? SdkError {
            self = error
        } else if let error = error {
            self = .generic(error: error)
        } else {
            self = .unknown
        }
    }
}


@objc(BDNFramework)
public enum Framework: UInt {
    case native
    case unity
    case reactNative
    case flutter
}


@objc
public enum AdType: Int, Codable {
    case banner = 0
    case interstitial = 1
    case rewarded = 2
    
    var stringValue: String {
        switch self {
        case .banner: return "banner"
        case .interstitial: return "interstitial"
        case .rewarded: return "rewarded"
        }
    }
    
    enum Key: CodingKey {
        case rawValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(stringValue, forKey: .rawValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let raw = try container.decode(String.self, forKey: .rawValue)
        switch raw {
        case "banner": self = .banner
        case "interstitial": self = .interstitial
        case "rewarded": self = .rewarded
        default:
            let ctx = DecodingError.Context(
                codingPath: [Key.rawValue],
                debugDescription: "Unsupported value '\(raw)'"
            )
            throw DecodingError.valueNotFound(AdType.self, ctx)
        }
    }
}


struct Constants {
    static let sdkVersion: String = "0.1.5"
    
    static let zeroUUID: String = "00000000-0000-0000-0000-000000000000"
    
    static let defaultPlacement: String = "default"
    
    struct API {
        static var host = "b.appbaqend.com"
        static var baseURL = "https://" + host
    }
    
    struct Adapters {
        static var clasess: [String] = [
            "BidonAdapterBidMachine.BidMachineDemandSourceAdapter",
            "BidonAdapterGoogleMobileAds.GoogleMobileAdsDemandSourceAdapter",
            "BidonAdapterAppLovin.AppLovinDemandSourceAdapter",
            "BidonAdapterDTExchange.DTExchangeDemandSourceAdapter",
            "BidonAdapterUnityAds.UnityAdsDemandSourceAdapter"
        ]
    }
    
    struct UserDefaultsKey {
        static var token = "BidonToken"
        static var idg = "BidonIdg"
        static var coppa = "BidonCoppa"
    }
}


extension AdType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .banner: return "Banner"
        case .interstitial: return "Interstitial"
        case .rewarded: return "Rewarded Ad"
        }
    }
}
