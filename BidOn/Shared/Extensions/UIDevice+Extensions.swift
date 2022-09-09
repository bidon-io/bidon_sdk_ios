//
//  UIDevice+Extensions.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.09.2022.
//

import Foundation
import UIKit


public extension UIDevice {
    static var bd: DSL = DSL()
    
    struct DSL {
        @MainThreadComputable(UIDevice.current.userInterfaceIdiom == .phone)
        public var isPhone: Bool
    }
}
