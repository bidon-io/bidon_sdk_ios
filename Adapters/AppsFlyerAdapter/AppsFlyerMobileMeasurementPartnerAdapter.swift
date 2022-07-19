//
//  AppsFlyerMobileMeasurementPartnerAdapter.swift
//  AppsFlyerAdapter
//
//  Created by Stas Kochkin on 19.07.2022.
//

import Foundation
import MobileAdvertising
import AppsFlyerLib
import AppsFlyerAdRevenue


@objc public final class AppsFlyerMobileMeasurementPartnerAdapter: NSObject {
    public let identifier: String = "appsflyer"
    public let parameters: AppsFlyerParameters
    
    public init(parameters: AppsFlyerParameters) {
        self.parameters = parameters
        super.init()
    }
}


extension AppsFlyerMobileMeasurementPartnerAdapter: ParameterizedAdapter {
    public typealias Parameters = AppsFlyerParameters
    
    @objc public convenience init(rawParameters: Data) throws {
        let parameters = try JSONDecoder().decode(
            AppsFlyerParameters.self,
            from: rawParameters
        )
        self.init(parameters: parameters)
    }
}


extension AppsFlyerMobileMeasurementPartnerAdapter: InitializableAdapter {
    public func initilize(_ completion: @escaping (Error?) -> ()) {
        AppsFlyerLib.shared().appsFlyerDevKey = parameters.devKey
        AppsFlyerLib.shared().appleAppID = parameters.appId
        AppsFlyerAdRevenue.start()
        AppsFlyerLib.shared().start { _, error in
            completion(error)
        }
    }
}


extension AppsFlyerMobileMeasurementPartnerAdapter: MobileMeasurementPartnerAdapter {
    public func trackAdRevenue(
        _ ad: Ad,
        mediation: Mediation,
        auctionRound: String,
        adType: AdType
    ) {
        let additionalParameters: [AnyHashable: Any] = [
            kAppsFlyerAdRevenueAdType: adType.rawValue,
            "auction_round": auctionRound,
            "demand_source_name": ad.dsp
        ].compactMapValues { $0 }
        
        AppsFlyerAdRevenue.shared().logAdRevenue(
            monetizationNetwork: ad.networkName,
            mediationNetwork: mediation.appsFlyer,
            eventRevenue: ad.price as NSNumber,
            revenueCurrency: ad.currency,
            additionalParameters: additionalParameters
        )
    }
}


extension Mediation {
    var appsFlyer: MediationNetworkType {
        switch self {
        case .applovin:     return .applovinMax
        case .fyber:        return .fyber
        case .ironsource:   return .ironSource
        }
    }
}
