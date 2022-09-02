//
//  User.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


enum TrackingAuthorizationStatus: UInt, Codable {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
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
