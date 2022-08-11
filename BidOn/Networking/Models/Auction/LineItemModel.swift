//
//  LineItemModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 10.08.2022.
//

import Foundation


struct LineItemModel: Decodable, LineItem {
    var id: String
    var pricefloor: Price
    var adUnitId: String
}
