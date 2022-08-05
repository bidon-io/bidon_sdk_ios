//
//  DeviceModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


#warning("Fill in all required fields")
protocol Device: Environment {
    var make: String { get }
}


struct CodableDevice: Device, Codable {
    var make: String
    
    init(_ device: Device) {
        self.make = device.make
    }
}
