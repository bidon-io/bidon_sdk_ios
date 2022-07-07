//
//  Auction.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 30.06.2022.
//

import Foundation


struct Auction<Round: Equatable> {
    enum AuctionError: Error {
        case roundNotFound
        case cycleDependency
    }
    
    private let rounds: [Round]
    private var edges: [Int: Set<Int>]
    
    var root: [Round] {
        return edges
            .reduce(Array(edges.keys)) { result, edge in
                return result.filter { !edge.value.contains($0) }
            }
            .compactMap { rounds[$0] }
    }
    
    init(rounds: [Round]) {
        self.rounds = rounds
        self.edges = rounds
            .enumerated()
            .map { $0.offset }
            .reduce([:]) { edges, offset in
                var edges = edges
                edges[offset] = Set()
                return edges
            }
    }
    
    mutating func addEdge(
        from fromRound: Round,
        to toRound: Round
    ) throws {
        guard
            let fromIndex = rounds.firstIndex(of: fromRound),
            let toIndex = rounds.firstIndex(of: toRound)
        else {
            throw AuctionError.roundNotFound
        }
        
        var toEdges = edges[fromIndex]
        toEdges?.insert(toIndex)
        edges[fromIndex] = toEdges
        
        // TODO: Validate graph
    }
    
    func seeds(of round: Round) -> [Round] {
        guard
            let idx = rounds.firstIndex(of: round),
            let seeds = edges[idx]
        else { return [] }
        return seeds.compactMap { rounds[$0] }
    }
}
