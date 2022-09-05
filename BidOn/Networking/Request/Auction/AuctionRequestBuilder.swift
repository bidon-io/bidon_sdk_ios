//
//  AuctionRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation


protocol AuctionRequestBuilder: BaseRequestBuilder {
    var adObject: AdObjectModel { get }
    var adapters: AdaptersInfo { get }
    var adType: AdType { get }
    
    @discardableResult
    func withPlacement(_ placement: String) -> Self
    
    @discardableResult
    func withAuctionId(_ auctionId: String) -> Self
    
    init()
}

