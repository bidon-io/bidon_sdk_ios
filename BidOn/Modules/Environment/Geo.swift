//
//  Geo.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


protocol Geo {
    var lat: Double { get }
    var lon: Double { get }
    var accuracy: UInt { get }
    var lastfix: UInt { get }
    var country: String? { get }
    var city: String? { get }
    var zip: String? { get }
    var utcoffset: Int { get }
}
