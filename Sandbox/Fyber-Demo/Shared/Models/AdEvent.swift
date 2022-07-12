//
//  AdEvent.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising


enum AdType {
    case banner
    case interstitial
    case rewardedVideo
}


struct AdEventModel: Identifiable {
    var id: UUID = UUID()
    var time: Date = Date()
    var adType: AdType
    var event: AdEvent
}

enum AdEvent {
    case didStartAuction(placement: String)
    case didStartAuctionRound(placement: String, id: String, pricefloor: Price)
    case didCompleteAuctionRound(placement: String, id: String)
    case didCompleteAuction(placement: String, ad: Ad?)
    case didReceive(placement: String, ad: Ad)
    case willRequest(placement: String)
    case isAvailable(placement: String)
    case isUnavailable(placement: String)
    case didShow(placement: String, impression: Ad)
    case didFailToShow(placement: String, impression: Ad, error: Error)
    case didClick(placement: String)
    case didDismiss(placement: String)
    case didComplete(placement: String, isRewarded: Bool)
}

extension AdEvent {
    var title: Text {
        switch self {
        case .didStartAuction: return Text("auction has been started")
        case .didStartAuctionRound(_, let id, _): return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been launched")
        case .didCompleteAuctionRound(_, let id): return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been ended")
        case .didCompleteAuction: return Text("auction has ended")
        case .didReceive: return Text("an ad was received")
        case .willRequest: return Text("ad will request")
        case .isAvailable: return Text("ad is available")
        case .isUnavailable: return Text("ad is unavailable")
        case .didShow: return Text("ad did show")
        case .didFailToShow: return Text("ad did fail to show")
        case .didClick: return Text("ad did click")
        case .didDismiss: return Text("ad did dismiss")
        case .didComplete(_, let isRewarded): return Text("ad completed, ") + Text(isRewarded ? "user was rewarded" : "user wasn't rewarded").bold()
        }
    }
    
    var subtitle: String {
        switch self {
        case .didStartAuction(let placement): return "Placement: " + placement
        case .didStartAuctionRound(let placement, _, let pricefloor): return "Placement: " + placement + ", pricefloor: " + pricefloor.pretty
        case .didCompleteAuctionRound(let placement, _): return "Placement: " + placement
        case .didCompleteAuction(let placement, _): return "Placement: " + placement
        case .didReceive(let placement, let ad): return "Placement: " + placement + ", impression: " + ad.text
        case .willRequest(let placement): return "Placement: " + placement
        case .isAvailable(let placement): return "Placement: " + placement
        case .isUnavailable(let placement): return "Placement: " + placement
        case .didClick(let placement): return "Placement: " + placement
        case .didDismiss(let placement): return "Placement: " + placement
        case .didComplete(let placement, _): return "Placement: " + placement
        case .didShow(let placement, let ad): return "Placement: " + placement + ", impression: " + ad.text
        case .didFailToShow(let placement, let ad, let error): return "Placement: " + placement + ", impression: " + ad.text + ", error: " + error.localizedDescription
        }
    }
    
    var systemImageName: String {
        switch self {
        case .didStartAuction, .didStartAuctionRound, .didCompleteAuction, .didCompleteAuctionRound: return "bolt"
        default: return "arrow.down"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .didStartAuction, .didStartAuctionRound, .didCompleteAuction, .didCompleteAuctionRound: return .orange
        default: return .primary
        }
    }
}


extension AdType {
    var title: Text {
        switch self {
        case .banner:
            return Text("[Banner]")
                .font(.system(size: 14, weight: .black, design: .monospaced))
        case .interstitial:
            return Text("[Interstitial]")
                .font(.system(size: 14, weight: .black, design: .monospaced))
        case .rewardedVideo:
            return Text("[Rewarded Video]")
                .font(.system(size: 14, weight: .black, design: .monospaced))
        }
    }
}


private extension Price {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var pretty: String {
        isUnknown ? "-" : Price.formatter.string(from: self as NSNumber) ?? "-"
    }
}


private extension Ad {
    var text: String {
        "Ad #\(id) from \(dsp), price: \(price.pretty)"
    }
}
