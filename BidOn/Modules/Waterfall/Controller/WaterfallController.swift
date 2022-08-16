//
//  WaterfallController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


protocol WaterfallControllerDelegate: AnyObject {
    func controller(
        _ controller: WaterfallController,
        didLoadDemand demand: Demand
    )
    
    func controller(
        _ controller: WaterfallController,
        didFailToLoad error: SdkError
    )
}


protocol WaterfallController {
    var delegate: WaterfallControllerDelegate? { get }
    
    func load()
}
