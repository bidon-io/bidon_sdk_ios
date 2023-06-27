//
//  MediationObserver.swift
//  Bidon
//
//  Created by Bidon Team on 05.09.2022.
//

import Foundation


protocol MediationObserver: AnyObject {
    associatedtype MediationAttemptReportType: MediationAttemptReport
    
    var report: MediationAttemptReportType { get }
    
    func log<EventType: MediationEvent>(_ event: EventType)
}


typealias AnyMediationObserver = (any MediationObserver)
