//
//  WaterfallController.swift
//  Bidon
//
//  Created by Bidon Team on 06.09.2022.
//

import Foundation


protocol WaterfallController {
    associatedtype DemandProviderType: DemandProvider
    associatedtype BidType: Bid where BidType.Provider == DemandProviderType

    typealias Completion = (Result<BidType, SdkError>) -> ()
    
    var bids: [BidType] { get }
    
    func load(completion: @escaping Completion)
}
