//
//  Defines.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 15.06.2022.
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


public enum AdType: String {
    case banner
    case interstitial
    case rewarded
}


struct Constants {
    struct API {
        static var host = "b.appbaqend.com"
        static var baseURL = "https://" + host
    }
    
    struct Adapters {
        static var clasess: [String] = [
            "BidOnAdapterBidMachine.BidMachineDemandSourceAdapter",
            "BidOnAdapterAppsFlyer.AppsFlyerMobileMeasurementPartnerAdapter",
            "BidOnAdapterGoogleMobileAds.GoogleMobileAdsDemandSourceAdapter",
            "BidOnAdapterAppLovin.AppLovinDemandSourceAdapter"
        ]
    }
    
    struct UserDefaultsKey {
        static var token = "BidOnToken"
    }
}