//
//  AdProvider.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 29.06.2022.
//

import Foundation


public enum AuctionEvent {
    case win
    case lose(DemandAd, Price)
}


public enum MediationError: String, Error {
    case noBid
    case noFill
    case unknownAdapter
    case adapterNotInitialized
    case bidTimeoutReached
    case fillTimeoutReached
    case networkError
    case incorrectAdUnitId
    case noAppropriateAdUnitId
    case auctionCancelled
    case adFormatNotSupported
    case unscpecifiedException
    case belowPricefloor
}


public typealias DemandProviderResponse = (Result<DemandAd, MediationError>) -> ()


public protocol DemandProviderDelegate: AnyObject {
    func providerWillPresent(_ provider: any DemandProvider)
    func providerDidHide(_ provider: any DemandProvider)
    func providerDidClick(_ provider: any DemandProvider)
    func providerDidFailToDisplay(_ provider: any DemandProvider, error: SdkError)
}


public protocol DemandProviderRevenueDelegate: AnyObject {
    func provider(
        _ provider: any DemandProvider,
        didPayRevenue revenue: AdRevenue,
        ad: DemandAd
    )
    
    func provider(
        _ provider: any DemandProvider,
        didLogImpression ad: DemandAd
    )
}
    

public protocol DemandProvider: AnyObject {
    associatedtype DemandAdType: DemandAd
    
    var delegate: DemandProviderDelegate? { get set }
    var revenueDelegate: DemandProviderRevenueDelegate? { get set }
    
    func fill(ad: DemandAdType, response: @escaping DemandProviderResponse)
    
    func notify(ad: DemandAdType, event: AuctionEvent)
}


internal extension DemandProvider {
    func fill(opaque ad: DemandAd, response: @escaping DemandProviderResponse) {
        guard let ad = ad as? DemandAdType else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        fill(ad: ad, response: response)
    }
    
    func notify(opaque ad: DemandAd, event: AuctionEvent) {
        guard let ad = ad as? DemandAdType else { return }
        notify(ad: ad, event: event)
    }
}


public protocol ProgrammaticDemandProvider: DemandProvider {
    func bid(
        _ pricefloor: Price,
        response: @escaping DemandProviderResponse
    )
}


public protocol DirectDemandProvider: DemandProvider {
    func bid(
        _ lineItem: LineItem,
        response: @escaping DemandProviderResponse
    )
}
