//
//  WaterfallProvider.swift
//  BidOn
//
//  Created by Stas Kochkin on 02.09.2022.
//

import Foundation


protocol WaterfallProvider {
    associatedtype DemandType: Demand
    
    var waterfall: Waterfall<DemandType> { get }
}
