//
//  GeoModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


struct GeoModel: Geo, Codable {
    var lat: Double
    
    init(_ geo: Geo) {
        self.lat = geo.lat
    }
}
