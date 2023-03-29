//
//  AuctionControllerDelegate.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 06.07.2022.
//

import Foundation


protocol AuctionController {
    associatedtype DemandProviderType: DemandProvider
    associatedtype BidType: Bid where BidType.Provider == DemandProviderType
    
    typealias WaterfallType = Waterfall<BidType>
    typealias Completion = (Result<WaterfallType, SdkError>) -> ()
        
    func load(completion: @escaping Completion)
}
