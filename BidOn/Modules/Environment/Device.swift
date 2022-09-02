//
//  DeviceModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


enum ConnectionType: Int, Codable {
    case unknown = 0
    case ethernet = 1
    case wifi = 2
    case cellularUnknown = 3
    case cellular2G = 4
    case cellular3G = 5
    case cellular4G = 6
    case cellular5G = 7
}


protocol Device {
    var userAgent: String { get }
    var make: String { get }
    var model: String { get }
    var os: String { get }
    var osVersion: String { get }
    var hardwareVersion: String { get }
    var pixelHeight: Int { get }
    var pixelWidth: Int { get }
    var ppi: Int { get }
    var pixelRatio: Float { get }
    var javaScript: Int { get }
    var language: String { get }
    var carrier: String? { get }
    var mccncc: String? { get }
    var conectionType: ConnectionType { get }
}
