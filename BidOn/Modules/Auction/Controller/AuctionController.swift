//
//  AuctionControllerDelegate.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation


protocol AuctionController {
    associatedtype DemandProviderType: DemandProvider
    associatedtype DemandType: Demand where DemandType.Provider == DemandProviderType
    
    typealias WaterfallType = Waterfall<DemandType>    
    typealias Completion = (Result<WaterfallType, SdkError>) -> ()
        
    func load(completion: @escaping Completion)
}
