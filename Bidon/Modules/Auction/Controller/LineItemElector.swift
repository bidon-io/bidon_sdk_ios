//
//  LineItemElector.swift
//  Bidon
//
//  Created by Bidon Team on 24.02.2023.
//

import Foundation


protocol LineItemElector {
    func lineItem(
        for demand: String,
        pricefloor: Price
    ) -> LineItem?
}


struct StrictLineItemElector<Observer: MediationObserver>: LineItemElector {
    fileprivate struct EquatableLineItem: LineItem, Equatable {
        private let _id: () -> String
        private let _pricefloor: () -> Price
        private let _adUnitId: () -> String
        
        var id: String { _id() }
        var pricefloor: Price { _pricefloor() }
        var adUnitId: String { _adUnitId() }
        
        init(_ lineItem: LineItem) {
            _id = { lineItem.id }
            _pricefloor = { lineItem.pricefloor }
            _adUnitId = { lineItem.adUnitId }
        }
        
        static func == (lhs: EquatableLineItem, rhs: EquatableLineItem) -> Bool {
            return lhs.id == rhs.id && lhs.pricefloor == rhs.pricefloor && lhs.adUnitId == rhs.adUnitId
        }
    }
    
    private var items: [EquatableLineItem]
    private var observer: Observer
    
    init(
        items: [LineItem],
        observer: Observer
    ) {
        self.items = items.map(EquatableLineItem.init)
        self.observer = observer
    }
    
    func lineItem(
        for demand: String,
        pricefloor: Price
    ) -> LineItem? {
        let firedLineItems = observer.firedLineItems.map(EquatableLineItem.init)
        let candidates = items.filter { $0.id == demand && !firedLineItems.contains($0) }
        
        guard !pricefloor.isUnknown else { return candidates.first }
        
        return candidates
            .sorted { $0.pricefloor < $1.pricefloor }
            .filter { $0.pricefloor > pricefloor }
            .first
    }
}


extension StrictLineItemElector.EquatableLineItem: CustomDebugStringConvertible {
    var debugDescription: String {
        return "line item '\(id)' with ad unit id: \(adUnitId), pricefloor: \(pricefloor)$"
    }
}
