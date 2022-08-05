//
//  Geo.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


#warning("Fill in all required fields")
protocol Geo: Environment {
    var lat: Float { get }
}


struct CodableGeo: Geo, Codable {
    var lat: Float
    
    init(_ geo: Geo) {
        self.lat = geo.lat
    }
}
