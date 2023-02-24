//
//  LineItem.swift
//  BidOn
//
//  Created by Stas Kochkin on 10.08.2022.
//

import Foundation


public protocol LineItem {
    var id: String { get }
    var pricefloor: Price { get }
    var adUnitId: String { get }
}
