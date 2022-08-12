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


public typealias DemandProviderResponse = (Result<Ad, Error>) -> ()


public protocol DemandProviderDelegate: AnyObject {
    func proivder(_ provider: DemandProvider, didLoad ad: Ad)
    func provider(_ provider: DemandProvider, didFailToLoad ad: Ad, error: Error)
    func provider(_ provider: DemandProvider, didPresent ad: Ad)
    func provider(_ provider: DemandProvider, didHide ad: Ad)
    func provider(_ provider: DemandProvider, didClick ad: Ad)
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error)
    func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad)
}


public protocol DemandProvider: AnyObject {
    var delegate: DemandProviderDelegate? { get set }
        
    func cancel()
    
    func load(ad: Ad)

    func notify(_ event: AuctionEvent)
}


public protocol ProgrammaticDemandProvider: DemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse)
}

public protocol DirectDemandProvider: DemandProvider {
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse)
}


