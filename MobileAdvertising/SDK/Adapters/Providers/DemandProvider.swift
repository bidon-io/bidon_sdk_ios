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


public typealias DemandProviderResponse = (Ad?, Error?) -> ()
 

public protocol DemandProviderDelegate: AnyObject {
    func provider(_ provider: DemandProvider, didPresent ad: Ad)
    func provider(_ provider: DemandProvider, didHide ad: Ad)
    func provider(_ provider: DemandProvider, didClick ad: Ad)
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error)
}


public protocol DemandProvider: AnyObject {
    var delegate: DemandProviderDelegate? { get set }
    
    @available (iOS 13, *)
    func request(pricefloor: Price) async throws -> Ad
    
    func request(pricefloor: Price, response: @escaping DemandProviderResponse)
    
    func notify(_ event: AuctionEvent) 
}
