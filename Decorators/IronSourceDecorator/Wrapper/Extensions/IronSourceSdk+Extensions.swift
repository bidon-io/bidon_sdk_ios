//
//  IronSourceSdk+Extensions.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 26.07.2022.
//

import Foundation
import IronSource



extension IronSource {
    private static var sdk: AnyObject? {
        let selector = NSSelectorFromString("sharedInstance")
        guard
            let _cls = NSClassFromString("IronSourceSdk"),
            let cls = (_cls as AnyObject) as? NSObjectProtocol,
            cls.responds(to: selector)
        else { return nil }
        
        return cls.perform(selector)?.takeUnretainedValue()
    }
    
    private static var bannerManager: AnyObject? {
        guard
            let sdk = sdk,
            let ivar = class_getInstanceVariable(type(of: sdk), "_progBannerManager")
        else { return nil }
        
        return object_getIvar(sdk, ivar) as? AnyObject
    }
    
    static var bannerRefreshInterval: TimeInterval {
        guard
            let manager = bannerManager,
            let ivar = class_getInstanceVariable(type(of: manager), "_bannerSettings"),
            let settings = object_getIvar(manager, ivar) as? AnyObject
        else { return 0 }
        
        return (settings.value(forKey: "bannerInterval") as? NSNumber)?.doubleValue ?? 0
    }
}
