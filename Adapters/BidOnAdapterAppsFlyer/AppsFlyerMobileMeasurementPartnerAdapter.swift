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
    
    private(set) var conversionData: [AnyHashable: Any]?
}


extension AppsFlyerMobileMeasurementPartnerAdapter: InitializableAdapter {
    public func initialize(from decoder: Decoder, completion: @escaping (Result<Void, SdkError>) -> Void) {
        var parameters: AppsFlyerParameters?
        
        do {
            parameters = try AppsFlyerParameters(from: decoder)
        } catch {
            completion(.failure(SdkError(error)))
        }
        
        guard let parameters = parameters else { return }
        
        AppsFlyerLib.shared().appsFlyerDevKey = parameters.devKey
        AppsFlyerLib.shared().appleAppID = parameters.appId
        AppsFlyerLib.shared().delegate = self
        
        AppsFlyerAdRevenue.start()
        AppsFlyerLib.shared().start { _, error in
            if let error = error {
                completion(.failure(SdkError(error)))
            } else {
                completion(.success(()))
            }
        }
    }
}


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


extension AppsFlyerMobileMeasurementPartnerAdapter: AppsFlyerLibDelegate {
    public func onConversionDataFail(_ error: Error) {}
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        conversionData = conversionInfo
    }
}
