//
//  User.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


enum TrackingAuthorizationStatus: String, Codable {
    case notDetermined
    case restricted
    case denied
    case authorized 
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue.camelCaseToSnakeCase().uppercased())
    }
}


protocol User {
    associatedtype Consent: Codable

    var idfa: String { get }
    var trackingAuthorizationStatus: TrackingAuthorizationStatus { get }
    var idfv: String { get }
    var idg: String { get }
    var coppa: Bool { get }
    var consent: Consent { get }
}
