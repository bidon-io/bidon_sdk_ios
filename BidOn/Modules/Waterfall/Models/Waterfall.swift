//
//  Waterfall.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation


typealias Waterfall = Queue<Demand>


struct Queue<T> {
    private var elements: [T] = []
    
    init<W>(_ sequence: W) where W: Sequence, W.Element == T {
        self.elements = Array(sequence)
    }
    
    mutating func next() -> T? {
        guard !elements.isEmpty else { return nil }
        
        return elements.removeFirst()
    }
}

