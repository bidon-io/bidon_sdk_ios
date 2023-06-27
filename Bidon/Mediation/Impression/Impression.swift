//
//  Impression.swift
//  Bidon
//
//  Created by Bidon Team on 30.08.2022.
//

import Foundation


protocol Impression: ECPMProvider {
    var impressionId: String { get }
    var roundId: String { get }
    var lineItem: LineItem? { get }
    var adType: AdType { get }
    var ad: DemandAd { get }
    var metadata: AuctionMetadata { get }
    
    var showTrackedAt: TimeInterval { get set }
    var clickTrackedAt: TimeInterval { get set }
    var rewardTrackedAt: TimeInterval { get set }
    var externalNotificationTrackedAt: TimeInterval { get set }
}


extension Impression {
    func isTrackingAllowed(_ path: Route) -> Bool {
        let keyPaths = path.readableTrackedAtKeyPaths(Self.self)
        return keyPaths.reduce(true) { $0 && self[keyPath: $1].isNaN }
    }
    
    mutating func markTrackedIfNeeded(_ path: Route) {
        guard let keyPath = path.writableTrackedAtKeyPath(Self.self) else { return }
        if self[keyPath: keyPath].isNaN {
            self[keyPath: keyPath] = Date.timestamp(.wall)
        }
    }
}


private extension Route {
    func readableTrackedAtKeyPaths<T: Impression>(_ type: T.Type) -> [WritableKeyPath<T, TimeInterval>] {
        switch self {
        case .show: return [\T.showTrackedAt]
        case .click: return [\T.clickTrackedAt]
        case .reward: return [\T.rewardTrackedAt]
        case .win, .loss: return [\T.showTrackedAt, \T.externalNotificationTrackedAt]
        default: return []
        }
    }
    
    func writableTrackedAtKeyPath<T: Impression>(_ type: T.Type) -> WritableKeyPath<T, TimeInterval>? {
        switch self {
        case .show: return \T.showTrackedAt
        case .click: return \T.clickTrackedAt
        case .reward: return \T.rewardTrackedAt
        case .win, .loss: return \T.externalNotificationTrackedAt
        default: return nil
        }
    }
}
