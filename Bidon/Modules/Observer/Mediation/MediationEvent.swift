//
//  MediationEvent.swift
//  Bidon
//
//  Created by Bidon Team on 07.09.2022.
//

import Foundation


enum MediationEvent {
    case auctionStart
    case roundStart(round: AuctionRound, pricefloor: Price)
    case bidRequest(round: AuctionRound, adapter: Adapter, lineItem: LineItem?)
    case bidResponse(round: AuctionRound, adapter: Adapter, bid: any Bid)
    case bidError(round: AuctionRound, adapter: Adapter, error: MediationError)
    case roundFinish(round: AuctionRound, winner: (any Bid)?)
    case auctionFinish(winner: (any Bid)?)
    case fillStart
    case fillRequest(bid: any Bid)
    case fillResponse(bid: any Bid)
    case fillError(bid: any Bid, error: MediationError)
    case fillFinish(winner: (any Bid)?)
}


extension MediationEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .auctionStart: return "did start auction"
        case .roundStart(let round, let pricefloor): return "did start round: \(round) with pricefloor: \(pricefloor.pretty)"
        case .bidRequest(let round, let adapter, let lineItem): return "\(adapter) will request bid" + (lineItem.map { " with \($0)" } ?? " (programmatic)" + " in round: '\(round.id)'")
        case .bidResponse(let round, let adapter, let ad): return "\(adapter) did receive bid: \(ad) in round: '\(round.id)'"
        case .bidError(let round, let adapter, let error): return "\(adapter) did fail with error: \(error) in round: '\(round.id)'"
        case .roundFinish(let round, let winner): return "\(round) finished" + (winner.map { " with winner: \($0)" } ?? " without winner")
        case .auctionFinish(winner: let winner): return "bidding finished" + (winner.map { " with winner: \($0)" } ?? " without winner")
        case .fillStart: return "will load bids"
        case .fillRequest(let ad): return "will fill \(ad)"
        case .fillResponse(let ad): return "did fill \(ad)"
        case .fillError(let ad, let error): return "did fail to fill \(ad) with error: \(error)"
        case .fillFinish(let winner): return "did finish, " + (winner.map { "\($0) is ready to present" } ?? "no ads to be presented")
        }
    }
}

