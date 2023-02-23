//
//  EventModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import BidOn
import SwiftUI


struct AdEventModel: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var adType: AdType
    var title: String
    var subtitle: String
    var bage: String
    var color: Color
}


extension AdType {
    var title: String {
        switch self {
        case .banner: return "[Banner]"
        case .interstitial: return "[Interstitial]"
        case .rewardedAd: return "[Rewarded Ad]"
        }
    }
}


extension Price {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    var pretty: String {
        isUnknown ? "-" : Price.formatter.string(from: self as NSNumber) ?? "-"
    }
}


extension Ad {
    var text: String {
        "Ad #\(id.prefix(3))... from \(networkName), eCPM: \(eCPM.pretty)"
    }
}


private extension Reward {
    var text: String {
        "Reward \(amount) of \(label)"
    }
}
