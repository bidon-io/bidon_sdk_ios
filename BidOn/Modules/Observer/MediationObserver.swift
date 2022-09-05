//
//  MediationObserver.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation



protocol MediationController {
    associatedtype Observer: MediationObserver
    
    var observer: Observer { get }
}


protocol MediationObserver {
    associatedtype MediationLogType: MediationLog
    
    var log: MediationLogType { get }
}
