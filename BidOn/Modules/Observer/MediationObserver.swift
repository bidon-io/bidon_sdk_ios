//
//  MediationObserver.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation


protocol MediationController {
    associatedtype Observer: MediationObserver
    
    var observer: Observer { get }
}


protocol MediationObserverDelegate: AnyObject {
    func didStartAuction(_ auctionId: String)
    func didStartAuctionRound(_ auctionRound: AuctionRound, pricefloor: Price)
    func didReceiveBid(_ ad: Ad, provider: DemandProvider)
    func didFinishAuctionRound(_ auctionRound: AuctionRound)
    func didFinishAuction(_ auctionId: String, winner: Ad?)
}

protocol MediationObserver: AnyObject {
    associatedtype MediationAttemptReportType: MediationAttemptReport
    associatedtype DemandProviderType: DemandProvider
    
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var adType: AdType { get }
    
    var delegate: MediationObserverDelegate? { get set }
    
    var report: MediationAttemptReportType { get }
    
    func log(_ event: MediationEvent<DemandProviderType>)
    
    init(
        auctionId: String,
        auctionConfigurationId: Int,
        adType: AdType
    )
}
