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
    case didLoad(placement: String)
    case didFailToLoad(placement: String, error: Error)
    case willPresentModalView(placement: String)
    case didDimissModalView(placement: String)
    case willLeaveApplication(placement: String)
    case didResize(placement: String, frame: CGRect)
}

extension AdEvent {
    var title: Text {
        switch self {
        case .didStartAuction:
            return Text("auction has been started")
        case .didStartAuctionRound(_, let id, _):
            return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been launched")
        case .didCompleteAuctionRound(_, let id):
            return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been ended")
        case .didCompleteAuction:
            return Text("auction has ended")
        case .didReceive:
            return Text("an ad was received")
        case .willRequest:
            return Text("ad will request")
        case .isAvailable:
            return Text("ad is available")
        case .isUnavailable:
            return Text("ad is unavailable")
        case .didShow:
            return Text("ad did show")
        case .didFailToShow:
            return Text("ad did fail to show")
        case .didClick:
            return Text("ad did click")
        case .didDismiss:
            return Text("ad did dismiss")
        case .didLoad:
            return Text("ad did load")
        case .didFailToLoad:
            return Text("ad did fail to load")
        case .willPresentModalView:
            return Text("ad will present modal view")
        case .willLeaveApplication:
            return Text("ad will leave application")
        case .didDimissModalView:
            return Text("ad did dismiss modal view")
        case .didResize(_, let frame):
            return Text("ad did resize to ") + Text(frame.debugDescription).bold()
        case .didComplete(_, let isRewarded):
            return Text("ad completed, ") + Text(isRewarded ? "user was rewarded" : "user wasn't rewarded").bold()
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didStartAuction(let placement):
            text = "Placement: " + placement
        case .didStartAuctionRound(let placement, _, let pricefloor):
            text = "Placement: " + placement + ", pricefloor: " + pricefloor.pretty
        case .didCompleteAuctionRound(let placement, _):
            text = "Placement: " + placement
        case .didCompleteAuction(let placement, _):
            text = "Placement: " + placement
        case .didReceive(let placement, let ad):
            text = "Placement: " + placement + ", impression: " + ad.text
        case .willRequest(let placement):
            text = "Placement: " + placement
        case .isAvailable(let placement):
            text = "Placement: " + placement
        case .isUnavailable(let placement):
            text = "Placement: " + placement
        case .didClick(let placement):
            text = "Placement: " + placement
        case .didDismiss(let placement):
            text = "Placement: " + placement
        case .didComplete(let placement, _):
            text = "Placement: " + placement
        case .didShow(let placement, let ad):
            text = "Placement: " + placement + ", impression: " + ad.text
        case .didFailToShow(let placement, let ad, let error):
            text = "Placement: " + placement + ", impression: " + ad.text + ", error: " + error.localizedDescription
        case .didLoad(let placement):
            text = "Placement: " + placement
        case .didFailToLoad(let placement, let error):
            text = "Placement: " + placement + ", error: " + error.localizedDescription
        case .willPresentModalView(let placement):
            text = "Placement: " + placement
        case .willLeaveApplication(let placement):
            text = "Placement: " + placement
        case .didDimissModalView(let placement):
            text = "Placement: " + placement
        case .didResize(let placement, _):
            text = "Placement: " + placement
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var bage: some View {
        switch self {
        case .didStartAuction, .didStartAuctionRound, .didCompleteAuction, .didCompleteAuctionRound:
            return Image(systemName: "bolt")
                .foregroundColor(.orange)
        case .didDimissModalView, .willPresentModalView, .willLeaveApplication, .didResize:
            return Image(systemName: "shield")
                .foregroundColor(.purple)
        default:
            return Image(systemName: "arrow.down")
                .foregroundColor(.primary)
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


extension Ad {
    var text: String {
        "Ad #\(id.prefix(3))... from \(dsp), price: \(price.pretty)"
    }
}
