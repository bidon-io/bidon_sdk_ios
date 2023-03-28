//
//  MediationObserver.swift
//  Bidon
//
//  Created by Bidon Team on 05.09.2022.
//

import Foundation


protocol MediationController {
    associatedtype Observer: MediationObserver
    
    var observer: Observer { get }
}


protocol MediationObserver: AnyObject {
    associatedtype MediationAttemptReportType: MediationAttemptReport
    associatedtype DemandProviderType: DemandProvider
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var adType: AdType { get }
    var firedLineItems: [LineItem] { get }
    var report: MediationAttemptReportType { get }
    
    func log(_ event: MediationEvent<DemandProviderType>)
    
    init(
        auctionId: String,
        auctionConfigurationId: Int,
        adType: AdType
    )
}
