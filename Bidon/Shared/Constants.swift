//
//  Defines.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 15.06.2022.
//

import Foundation


struct Constants {
    static let sdkVersion: String = "0.2.0"
    
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
