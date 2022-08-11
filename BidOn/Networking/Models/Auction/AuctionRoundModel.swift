//
//  AuctionRoundModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 10.08.2022.
//

import Foundation


struct AuctionRoundModel: Decodable, AuctionRound {
    var id: String
    var timeout: TimeInterval
    var demands: [String]
}

