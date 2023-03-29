//
//  Atomic.swift
//  Bidon
//
//  Created by Bidon Team on 31.08.2022.
//

import Foundation


@propertyWrapper
struct Atomic<Value> {
    private let queue = DispatchQueue(label: "com.bidon.atomic.queue")
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
