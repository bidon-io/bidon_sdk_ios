//
//  Waterfall.swift
//  Bidon
//
//  Created by Bidon Team on 12.08.2022.
//

import Foundation


typealias Waterfall<BidType: Bid> = Queue<BidType>


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

