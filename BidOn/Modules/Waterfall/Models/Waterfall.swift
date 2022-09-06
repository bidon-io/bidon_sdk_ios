//
//  Waterfall.swift
//  BidOn
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation


typealias Waterfall<DemandType: Demand> = Queue<DemandType>


struct Queue<T> {
    private var elements: [T] = []
    
    init<W>(_ sequence: W) where W: Sequence, W.Element == T {
        self.elements = Array(sequence)
    }
    
    func first() -> T? {
        return elements.first
    }
    
    mutating func next() -> T? {
        guard !elements.isEmpty else { return nil }
        
        return elements.removeFirst()
    }
}

