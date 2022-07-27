//
//  MobileMeasurementPartnerAdapter.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 19.07.2022.
//

import Foundation


public protocol MobileMeasurementPartnerAdapter: Adapter {
    func trackAdRevenue(
        _ ad: Ad,
        mediation: Mediation,
        auctionRound: String,
        adType: AdType
    )
}
