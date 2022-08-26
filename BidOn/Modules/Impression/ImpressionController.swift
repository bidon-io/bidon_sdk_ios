//
//  ImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


protocol ImpressionController: AnyObject {
    associatedtype Context

    init(demand: Demand) throws
    
    func show(from context: Context)
}
