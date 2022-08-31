//
//  AppsFlyerMobileMeasurementPartnerAdapter.swift
//  AppsFlyerAdapter
//
//  Created by Stas Kochkin on 19.07.2022.
//

import Foundation
import BidOn
import AppsFlyerLib
import AppsFlyerAdRevenue


@objc public final class AppsFlyerMobileMeasurementPartnerAdapter: NSObject {
    public let identifier: String = "appsflyer"
    public let name: String = "AppsFlyer"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = AppsFlyerLib.shared().getSDKVersion()
    
    var conversionData: [String: Any]?
    
    //    public init(parameters: AppsFlyerParameters) {
    ////        self.parameters = parameters
    //        super.init()
    //    }
}


//extension AppsFlyerMobileMeasurementPartnerAdapter: ParameterizedAdapter {
//    public typealias Parameters = AppsFlyerParameters
//
//    @objc public convenience init(rawParameters: Data) throws {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        let parameters = try decoder.decode(
//            AppsFlyerParameters.self,
//            from: rawParameters
//        )
//
//        self.init(parameters: parameters)
//    }
//}


//extension AppsFlyerMobileMeasurementPartnerAdapter: InitializableAdapter {
//    public func initilize(_ completion: @escaping (Error?) -> ()) {
//        AppsFlyerLib.shared().appsFlyerDevKey = parameters.devKey
//        AppsFlyerLib.shared().appleAppID = parameters.appId
//        AppsFlyerAdRevenue.start()
//        AppsFlyerLib.shared().start { _, error in
//            completion(error)
//        }
//    }
//}


extension AppsFlyerMobileMeasurementPartnerAdapter: ParametersEncodableAdapter {
    public func encodeAdapterParameters(to encoder: Encoder) throws {
        struct Parameters: Encodable {
            var attributionId: String
            var converstionData: String?
        }
        
        let attributionId = AppsFlyerLib.shared().getAppsFlyerUID()
        let conversionData = self.conversionData
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { String(data: $0, encoding: .utf8) }
        
        let parameters = Parameters(
            attributionId: attributionId,
            converstionData: conversionData
        )
        
        try parameters.encode(to: encoder)
    }
}


extension AppsFlyerMobileMeasurementPartnerAdapter: MobileMeasurementPartnerAdapter {
    public var attributionIdentifier: String? {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    public func trackAdRevenue(
        _ ad: Ad,
        adType: AdType
    ) {
        let additionalParameters: [AnyHashable: Any] = [
            kAppsFlyerAdRevenueAdType: adType.rawValue,
            "demand_source_name": ad.dsp
        ].compactMapValues { $0 }
        
        AppsFlyerAdRevenue.shared().logAdRevenue(
            monetizationNetwork: ad.networkName,
            mediationNetwork: .appodeal,
            eventRevenue: ad.price as NSNumber,
            revenueCurrency: ad.currency,
            additionalParameters: additionalParameters
        )
    }
}

