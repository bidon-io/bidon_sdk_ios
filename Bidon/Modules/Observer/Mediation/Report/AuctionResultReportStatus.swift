//
//  AuctionResultReport.swift
//  Bidon
//
//  Created by Stas Kochkin on 03.03.2023.
//

import Foundation


enum AuctionResultReportStatus: Codable {
    case success
    case fail
    
    private var stringValue: String {
        switch self {
        case .success:          return "SUCCESS"
        case .fail:             return "FAIL"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "SUCCESS": self = .success
        case "FAIL": self = .fail
        default:
            let ctx = DecodingError.Context(
                codingPath: [],
                debugDescription: "Unable to create AuctionResultStatus from '\(value)'"
            )
            throw DecodingError.dataCorrupted(ctx)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}
