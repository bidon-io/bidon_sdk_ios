//
//  Atomic.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


@propertyWrapper
struct Atomic<Value> {
    private let queue = DispatchQueue(label: "com.bidon.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
}
