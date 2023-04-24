//
//  AcyclicGraph.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


struct GraphNode<T> {
    var value: T
    var children: [GraphNode<T>]
    
    init(value: T, children: [GraphNode<T>] = []) {
        self.value = value
        self.children = children
    }
    
    mutating func add(child: GraphNode<T>) {
        children.append(child)
    }
}


struct Graph<T> {
    
}
