//
//  MediationEvent.swift
//  Bidon
//
//  Created by Bidon Team on 07.09.2022.
//

import Foundation


enum MediationEvent {
    case auctionStart
    
    case roundStart(
        round: AuctionRound,
        pricefloor: Price
    )
    
    case unknownAdapter(
        round: AuctionRound,
        adapter: Adapter
    )
    
    case lineItemNotFound(
        round: AuctionRound,
        adapter: Adapter
    )
    
    case loadRequest(
        round: AuctionRound,
        adapter: Adapter,
        lineItem: LineItem
    )
    
    case loadResponse(
        round: AuctionRound,
        adapter: Adapter,
        bid: any Bid
    )
    
    case loadError(
        round: AuctionRound,
        adapter: Adapter,
        error: MediationError
    )
    
    case bidRequest(
        round: AuctionRound,
        adapter: Adapter
    )
    
    case bidResponse(
        round: AuctionRound,
        adapter: Adapter,
        bid: any Bid
    )
    
    case bidError(
        round: AuctionRound,
        adapter: Adapter,
        error: MediationError
    )
    
    case fillRequest(
        round: AuctionRound,
        adapter: Adapter,
        bid: any Bid
    )
    
    case fillResponse(
        round: AuctionRound,
        adapter: Adapter,
        bid: any Bid
    )
    
    case fillError(
        round: AuctionRound,
        adapter: Adapter,
        bid: any Bid,
        error: MediationError
    )
    
    case roundFinish(
        round: AuctionRound,
        winner: (any Bid)?
    )
    
    case auctionFinish(
        winner: (any Bid)?
    )
}


extension MediationEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .auctionStart:
            return "did start auction"
        case .roundStart(let round, let pricefloor):
            return "did start round: \(round) with pricefloor: \(pricefloor.pretty)"
        case .unknownAdapter(let round, let adapter):
            return "unsupported \(adapter) was found in round '\(round.id)'"
        case .lineItemNotFound(let round, let adapter):
            return "no appropriate ad unit for \(adapter) was found in round '\(round.id)'"
        case .loadRequest(let round, let adapter, let lineItem):
            return "\(adapter) will load \(lineItem) in round: '\(round.id)'"
        case .loadResponse(let round, let adapter, let bid):
            return "\(adapter) did load \(bid) in round: '\(round.id)'"
        case .loadError(let round, let adapter, let error):
            return "\(adapter) did fail to load \(error) in round: '\(round.id)'"
        case .bidRequest(let round, let adapter):
            return "\(adapter) will request bid in round: '\(round.id)'"
        case .bidResponse(let round, let adapter, let ad):
            return "\(adapter) did receive bid: \(ad) in round: '\(round.id)'"
        case .bidError(let round, let adapter, let error):
            return "\(adapter) did receive bid error: \(error) in round: '\(round.id)'"
        case .fillRequest(let round, let adapter, let bid):
            return "\(adapter) will fill \(bid) in round: '\(round.id)'"
        case .fillResponse(let round, let adapter, let bid):
            return "\(adapter) did fill \(bid) in round: '\(round.id)'"
        case .fillError(let round, let adapter, let bid, let error):
            return "\(adapter) did fail to fill \(bid) \(error) in round: '\(round.id)'"
        case .roundFinish(let round, let winner):
            return "\(round) finished " +
            (winner.map { "with winner: \($0)" } ?? "without winner")
        case .auctionFinish(let winner):
            return "did finish auction " +
            (winner.map { "with winner: \($0)" } ?? "without winner")
        }
    }
}

