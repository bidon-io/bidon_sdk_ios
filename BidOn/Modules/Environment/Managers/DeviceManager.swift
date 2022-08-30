//
//  DeviceManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation
import UIKit


final class DeviceManager: Device {
    let make: String = "Apple"
    
    @MainThreadComputable(UIDevice.current.model)
    var model: String
}
