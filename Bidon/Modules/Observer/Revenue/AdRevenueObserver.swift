//
//  AdRevenueObserver.swift
//  Bidon
//
//  Created by Stas Kochkin on 30.03.2023.
//

import Foundation


typealias RegisterAdRevenue = (Ad, AdRevenue) -> ()


protocol AdRevenueObserver {
    var onRegisterAdRevenue: RegisterAdRevenue? { get set }
    
    func observe<BidType>(_ bid: BidType)
    where BidType: Bid, BidType.Provider: DemandProvider
}
