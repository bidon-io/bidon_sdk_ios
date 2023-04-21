//
//  AcyclicGraph.swift
//  Bidon
//
//  Created by Stas Kochkin on 21.04.2023.
//

import Foundation


struct DirectedAcyclicGraph<Node: Equatable & CustomStringConvertible> {
    enum GraphError: Error {
        case nodeNotFound
        case cycleDependency
    }
    
    private let nodes: [Node]
    private var edges: [Int: Set<Int>]
    
    var root: [Node] {
        return edges
            .reduce(Array(edges.keys)) { result, edge in
                return result.filter { !edge.value.contains($0) }
            }
            .compactMap { nodes[$0] }
    }
    
    var width: Int {
        edges.reduce(0) { max($0, $1.value.count) }
    }
    
    init(nodes: [Node]) {
        self.nodes = nodes
        self.edges = nodes
            .enumerated()
            .map { $0.offset }
            .reduce([:]) { edges, offset in
                var edges = edges
                edges[offset] = Set()
                return edges
            }
    }
    
    mutating func addEdge(
        from fromNode: Node,
        to toNode: Node
    ) throws {
        guard
            let fromIndex = nodes.firstIndex(of: fromNode),
            let toIndex = nodes.firstIndex(of: toNode)
        else {
            throw GraphError.nodeNotFound
        }
        
        var toEdges = edges[fromIndex]
        toEdges?.insert(toIndex)
        edges[fromIndex] = toEdges
        
        // TODO: Validate graph
    }
    
    func seeds(of node: Node) -> [Node] {
        guard
            let idx = nodes.firstIndex(of: node),
            let seeds = edges[idx]
        else { return [] }
        return seeds.compactMap { nodes[$0] }
    }
}


extension DirectedAcyclicGraph: CustomStringConvertible {
    var description: String {
        let nodes = nodes.map { (root.contains($0) ? "(Root)" : "") + $0.description }.joined(separator: ", ")
        return "DAG with nodes: [\(nodes)]"
    }
}
