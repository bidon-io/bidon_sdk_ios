//
//  Waterfall.swift
//  Bidon
//
//  Created by Bidon Team on 12.08.2022.
//

import Foundation


typealias Waterfall<BidType: Bid> = Queue<BidType>


struct Queue<T> {
    fileprivate var elements: [T] = []
    
    var isEmpty: Bool { elements.isEmpty }
    
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


extension Queue: CustomStringConvertible {
    var description: String {
        return elements.description
    }
}


extension Array where Element: Bid {
    init(waterfall: Waterfall<Element>) {
        self = waterfall.elements
    }
}
