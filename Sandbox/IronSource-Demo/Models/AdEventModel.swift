//
//  File.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising
import IronSource


enum AdEvent {
    case didStartAuction
    case didStartAuctionRound(id: String, pricefloor: Price)
    case didCompleteAuctionRound(id: String)
    case didCompleteAuction(ad: Ad?)
    case didReceive(ad: Ad)
    case didChangeAvailability(isAvailable: Bool)
    case didFail(error: Error)
    case didOpen
    case didStart
    case didEnd
    case didClose
    case didFailToShow(error: Error)
    case didClick(placment: ISPlacementInfo)
    case didReceiveReward(placment: ISPlacementInfo)
}


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


extension AdEvent {
    var title: Text {
        switch self {
        case .didStartAuction: return Text("auction has been started")
        case .didStartAuctionRound(let id, _): return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been launched")
        case .didCompleteAuctionRound(let id): return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been ended")
        case .didCompleteAuction: return Text("auction has ended")
        case .didReceive: return Text("ad was received")
        case .didChangeAvailability(let isAvailable):
            return Text("did change availability. ") + Text(isAvailable ? "Ad is available" : "Ad is unavailable").bold()
        case .didFail: return Text("ad is not ready for show")
        case .didOpen: return Text("ad did open")
        case .didEnd: return Text("ad did end")
        case .didStart: return Text("ad did start")
        case .didClose: return Text("ad did close")
        case .didClick: return Text("ad did click")
        case .didFailToShow: return Text("ad did fail to show")
        case .didReceiveReward: return Text("ad did receive reward")
        }
    }
    
    var subtitle: String {
        switch self {
        case .didStartAuctionRound(_, let pricefloor): return "Pricefloor: \(pricefloor.pretty)"
        case .didReceive(let ad): return ad.text
        case .didFailToShow(let error): return error.localizedDescription
        case .didClick(let placement): return placement.description
        case .didReceiveReward(let placement): return placement.description
        default: return ""
        }
    }
    
    var systemImageName: String {
        switch self {
        case .didStartAuction, .didCompleteAuction, .didStartAuctionRound, .didCompleteAuctionRound: return "bolt"
        default: return "arrow.down"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .didStartAuction, .didCompleteAuction, .didStartAuctionRound, .didCompleteAuctionRound: return .orange
        case .didReceive: return .blue
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
