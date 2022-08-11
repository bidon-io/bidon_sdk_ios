//
//  DeviceModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


struct DeviceModel: Device, Codable {
    var make: String
    
    init(_ device: Device) {
        self.make = device.make
    }
}
