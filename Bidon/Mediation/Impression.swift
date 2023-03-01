//
//  Impression.swift
//  Bidon
//
//  Created by Bidon Team on 30.08.2022.
//

import Foundation


protocol Impression {
    var impressionId: String { get }
    var auctionId: String { get }
    var auctionConfigurationId: Int { get }
    var ad: Ad { get }
    
    var showTrackedAt: TimeInterval { get set }
    var clickTrackedAt: TimeInterval { get set }
    var rewardTrackedAt: TimeInterval { get set }
}


extension Impression {
    func isTrackingAllowed(_ path: Route) -> Bool {
        guard let keyPath = path.trackedAtKeyPath(Self.self) else { return true }
        return self[keyPath: keyPath].isNaN
    }
    
    mutating func markTrackedIfNeeded(_ path: Route) {
        guard let keyPath = path.trackedAtKeyPath(Self.self) else { return }
        if self[keyPath: keyPath].isNaN {
            self[keyPath: keyPath] = Date.timestamp(.wall)
        }
    }
}


private extension Route {
    func trackedAtKeyPath<T: Impression>(_ type: T.Type) -> WritableKeyPath<T, TimeInterval>? {
        switch self {
        case .show: return \T.showTrackedAt
        case .click: return \T.clickTrackedAt
        case .reward: return \T.rewardTrackedAt
        default: return nil
        }
    }
}
