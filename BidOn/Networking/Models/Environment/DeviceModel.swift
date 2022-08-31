//
//  DeviceModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


struct DeviceModel: Device, Codable {
    var userAgent: String
    var make: String
    var model: String
    var os: String
    var osVersion: String
    var hardwareVersion: String
    var pixelHeight: Int
    var pixelWidth: Int
    var ppi: Int
    var pixelRatio: Float
    var javaScript: Int
    var language: String
    var carrier: String?
    var mccncc: String?
    var conectionType: ConnectionType
    
    init(_ device: Device) {
        self.userAgent = device.userAgent
        self.make = device.make
        self.model = device.model
        self.os = device.os
        self.osVersion = device.osVersion
        self.hardwareVersion = device.hardwareVersion
        self.pixelHeight = device.pixelHeight
        self.pixelWidth = device.pixelWidth
        self.ppi = device.pixelHeight
        self.pixelRatio = device.pixelRatio
        self.javaScript = device.javaScript
        self.language = device.language
        self.carrier = device.carrier
        self.mccncc = device.mccncc
        self.conectionType = device.conectionType
    }
    
    enum CodingKeys: String, CodingKey {
        case userAgent = "ua"
        case make = "make"
        case model = "model"
        case os = "os"
        case osVersion = "osv"
        case hardwareVersion = "hwv"
        case pixelHeight = "h"
        case pixelWidth = "w"
        case ppi = "ppi"
        case pixelRatio = "pxratio"
        case javaScript = "js"
        case language = "language"
        case carrier = "carrier"
        case mccncc = "mccmnc"
        case conectionType = "connection_type"
    }
}
