//
//  DeviceManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation
import UIKit
import WebKit
import CoreTelephony
import SystemConfiguration
import Network


final class DeviceManager: Device {
    @MainThreadComputable(DeviceManager.userAgent)
    var userAgent: String
    
    let make: String = "Apple"
    
    @MainThreadComputable(UIDevice.current.model)
    var model: String
    
    @MainThreadComputable(UIDevice.current.systemName)
    var os: String
    
    @MainThreadComputable(UIDevice.current.systemVersion)
    var osVersion: String
    
    var hardwareVersion: String {
        var system = utsname()
        uname(&system)
        let mirror = Mirror(reflecting: system.machine)
        return mirror.children.reduce("") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    @MainThreadComputable(Int(UIScreen.main.bounds.height * UIScreen.main.scale))
    var pixelHeight: Int
    
    @MainThreadComputable(Int(UIScreen.main.bounds.width * UIScreen.main.scale))
    var pixelWidth: Int
    
    @MainThreadComputable(Int(UIScreen.main.scale * DeviceManager.scaleFactor))
    var ppi: Int
    
    @MainThreadComputable(Float(UIScreen.main.scale))
    var pixelRatio: Float
    
    let javaScript: Int = 1
    
    var language: String {
        Locale.preferredLanguages.first ?? ""
    }
    
    var carrier: String? {
        currentCarrier?.carrierName
    }
    
    var mccncc: String? {
        guard let carrier = currentCarrier else { return nil }
        return [
            carrier.mobileCountryCode,
            carrier.mobileNetworkCode
        ]
            .compactMap { $0 }
            .joined(separator: "-")
    }
    
    var currentCarrier: CTCarrier? {
        if #available(iOS 12, *) {
            let carriers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders
            return carriers?.first?.value
        } else {
            return CTTelephonyNetworkInfo().subscriberCellularProvider
        }
    }
    
    var conectionType: ConnectionType = .unknown
}


private extension DeviceManager {
    static let userAgent: String = {
        return (WKWebView().value(forKey: "userAgent") as? String) ?? ""
    }()
    
    static let scaleFactor: CGFloat = {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return 132
        default: return 163
        }
    }()
}


struct Reachability {
    var host: String = Constants.API.host
    
    var isReachable: Bool { flags.map { $0.contains(.reachable) } ?? false }
    
    private var flags: SCNetworkReachabilityFlags? {
        guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, Constants.API.host) else { return nil }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        return flags
    }
    
    var connectionType: ConnectionType {
        guard let flags = flags else { return .unknown }
        return .unknown
    }
}
