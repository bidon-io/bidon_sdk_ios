//
//  ImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation


protocol ImpressionController {
    associatedtype Context
    
    func show(from context: Context)
}
