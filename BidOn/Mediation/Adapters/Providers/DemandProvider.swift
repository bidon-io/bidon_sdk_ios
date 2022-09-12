//
//  AdProvider.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation


public enum AuctionEvent {
    case win(Ad)
    case lose(Ad)
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


public enum DemandProviderCancellationReason {
    case timeoutReached
    case lifecycle
}


public typealias DemandProviderResponse = (Result<Ad, MediationError>) -> ()


public protocol DemandProviderDelegate: AnyObject {
    func providerWillPresent(_ provider: DemandProvider)
    func providerDidHide(_ provider: DemandProvider)
    func providerDidClick(_ provider: DemandProvider)
    func providerDidFailToDisplay(_ provider: DemandProvider, error: SdkError)
}


public protocol DemandProviderRevenueDelegate: AnyObject {
    func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad)
}
    

public protocol DemandProvider: AnyObject {
    var delegate: DemandProviderDelegate? { get set }
    
    var revenueDelegate: DemandProviderRevenueDelegate? { get set }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse)

    func cancel(_ reason: DemandProviderCancellationReason)
    
    func notify(_ event: AuctionEvent)
}


public protocol ProgrammaticDemandProvider: DemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse)
}


public protocol DirectDemandProvider: DemandProvider {
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse)
}
