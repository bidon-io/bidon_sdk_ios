//
//  MobileMeasurementPartnerAdapter.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 19.07.2022.
//

import Foundation


public protocol MobileMeasurementPartnerAdapter: Adapter {
    var attributionIdentifier: String? { get }
    
    func trackAdRevenue(
        _ ad: Ad,
        adType: AdType
    )
}
