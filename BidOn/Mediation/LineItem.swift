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


typealias LineItems = [LineItem]


extension LineItems {
    func item(
        for demand: String,
        pricefloor: Price
    ) -> LineItem? {
        let candidates = filter { $0.id == demand }
        guard !pricefloor.isUnknown else { return candidates.first }
        return candidates
            .sorted { $0.pricefloor < $1.pricefloor }
            .filter { $0.pricefloor > pricefloor }
            .first
    }
}
