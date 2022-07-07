//
//  AdEvent.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising


enum AdEvent {
    case didStartAuction
    case didStartAuctionRound(id: String, pricefloor: Price)
    case didCompleteAuctionRound(id: String)
    case didCompleteAuction(ad: Ad?)
    case didReceive(ad: Ad)
    case didLoad(ad: Ad)
    case didFail(id: String, error: Error)
    case didDisplay(ad: Ad)
    case didHide(ad: Ad)
    case didClick(ad: Ad)
    case didDisplayFail(ad: Ad, error: Error)
    case didPay(ad: Ad)
    case didGenerateCreativeId(id: String, ad: Ad)
    case didReward(ad: Ad, reward: Reward)
}

extension AdEvent {
    var title: Text {
        switch self {
        case .didStartAuction: return Text("The auction has been started")
        case .didStartAuctionRound(let id, _): return Text("A round of auction ") + Text("\"\(id)\"").bold() + Text(" has been launched")
        case .didCompleteAuctionRound(let id): return Text("Auction round ") + Text("\"\(id)\"").bold() + Text(" has been ended")
        case .didCompleteAuction: return Text("The auction has ended")
        case .didReceive: return Text("An ad was received")
        case .didLoad: return Text("Ad is ready to show")
        case .didFail: return Text("No ad is ready for show")
        case .didDisplay: return Text("The ad was shown")
        case .didPay: return Text("Revenue was received from an ad")
        case .didHide: return Text("The ad did hide")
        case .didClick: return Text("The Ad has been clicked")
        case .didDisplayFail: return Text("An attempt to display ads was unsuccessful")
        case .didGenerateCreativeId: return Text("The ad did generate creative id")
        case .didReward(_, let reward): return Text("The ad did receive reward: ") + Text("\"\(reward.amount)\"").bold() + Text(" of ") + Text(reward.label).bold()
        }
    }
    
    var subtitle: String {
        switch self {
        case .didStartAuction: return ""
        case .didStartAuctionRound(_, let pricefloor): return "Pricefloor: \(pricefloor.pretty)"
        case .didCompleteAuctionRound: return ""
        case .didCompleteAuction: return ""
        case .didPay(let ad): return ad.text
        case .didReward(let ad, _): return ad.text
        case .didHide(let ad): return ad.text
        case .didClick(let ad): return ad.text
        case .didLoad(let ad): return ad.text
        case .didReceive(let ad): return ad.text
        case .didDisplay(ad: let ad): return ad.text
        case .didGenerateCreativeId(let id, let ad): return "CID: \(id), \(ad)"
        case .didDisplayFail(_, let error): return error.localizedDescription
        case .didFail(_, let error): return error.localizedDescription
        }
    }
    
    var systemImageName: String {
        switch self {
        case .didStartAuction, .didCompleteAuction, .didStartAuctionRound, .didCompleteAuctionRound: return "bolt"
        case .didReceive: return "cart"
        case .didGenerateCreativeId: return "magnifyingglass"
        case .didPay: return "banknote"
        default: return "arrow.down"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .didStartAuction, .didCompleteAuction, .didStartAuctionRound, .didCompleteAuctionRound: return .orange
        case .didReceive: return .blue
        case .didGenerateCreativeId: return .purple
        case .didPay: return .green
        default: return .primary
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
