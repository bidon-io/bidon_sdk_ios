//
//  AdEvent.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising
import FyberDecorator


enum AdType {
    case banner
    case interstitial
    case rewardedVideo
}


protocol AdEventViewRepresentable {
    var title: Text { get }
    var subtitle: Text { get }
    var image: Image { get }
    var accentColor: Color { get }
}

struct AdEventModel: Identifiable {
    var id: UUID = UUID()
    var time: Date = Date()
    var adType: AdType
    var event: AdEventViewRepresentable
}


extension BNFYBBannerPublisher {
    enum NoViewEvent {
        case bannerWillRequest(placement: String)
        case bannerDidLoad(placement: String)
        case bannerDidFailToLoad(placement: String, error: Error)
        case bannerDidShow(placement: String, impressionData: Ad)
        case bannerDidClick(placement: String)
        case bannerWillPresentModalView(placement: String)
        case bannerDidDismissModalView(placement: String)
        case bannerWillLeaveApplication(placement: String)
        case bannerDidResizeToFrame(placement: String, frame: CGRect)
        
        init(_ event: BNFYBBannerPublisher.Event) {
            switch event {
        
            case .bannerWillRequest(let placement):
                self = .bannerWillRequest(placement: placement)
            case .bannerDidLoad(let banner):
                self = .bannerDidLoad(placement: banner.options.placementId)
            case .bannerDidFailToLoad(let placement, let error):
                self = .bannerDidFailToLoad(placement: placement, error: error)
            case .bannerDidShow(let banner, let impressionData):
                self = .bannerDidShow(placement: banner.options.placementId, impressionData: impressionData)
            case .bannerDidClick(let banner):
                self = .bannerDidClick(placement: banner.options.placementId)
            case .bannerWillPresentModalView(let banner):
                self = .bannerWillPresentModalView(placement: banner.options.placementId)
            case .bannerDidDismissModalView(let banner):
                self = .bannerDidDismissModalView(placement: banner.options.placementId)
            case .bannerWillLeaveApplication(let banner):
                self = .bannerWillLeaveApplication(placement: banner.options.placementId)
            case .bannerDidResizeToFrame(let banner, let frame):
                self = .bannerDidResizeToFrame(placement: banner.options.placementId, frame: frame)
            }
        }
    }
}

extension BNFYBAuctionPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didStartAuction:
            return Text("auction has been started")
        case .didStartAuctionRound(let id, _, _):
            return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been launched")
        case .didCompleteAuctionRound(let id, _):
            return Text("auction round ") + Text("\"\(id)\"").bold() + Text(" has been ended")
        case .didCompleteAuction:
            return Text("auction has ended")
        case .didReceiveAd:
            return Text("auction did receive ad")
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didStartAuction(let placement):
            text = "Placement: " + placement
        case .didStartAuctionRound(_, let placement, let pricefloor):
            text = "Placement: " + placement + ", pricefloor: " + pricefloor.pretty
        case .didCompleteAuctionRound(_, let placement):
            text = "Placement: " + placement
        case .didCompleteAuction(let ad, let placement):
            text = "Placement: " + placement + (ad.map { ", winner: \($0)" } ?? ". No winner")
        case .didReceiveAd(let ad, let placement):
            text = "Placement: " + placement + ", impression: " + ad.text
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        switch self {
        case .didReceiveAd:
            return Image(systemName: "cart")
        default:
            return Image(systemName: "bolt")
        }
    }
    
    var accentColor: Color {
        return .orange
    }
}


extension BNFYBInterstitialPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .interstitialWillRequest:
            return Text("ad will request")
        case .interstitialIsAvailable:
            return Text("ad is available")
        case .interstitialDidFailToShow:
            return Text("ad did fail to show")
        case .interstitialIsUnavailable:
            return Text("ad is unavailable")
        case .interstitialDidShow:
            return Text("ad did show")
        case .interstitialDidClick:
            return Text("ad did click")
        case .interstitialDidDismiss:
            return Text("ad did dismiss")
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .interstitialWillRequest(let placement):
            text = "Placement: " + placement
        case .interstitialIsAvailable(let placement):
            text = "Placement: " + placement
        case .interstitialIsUnavailable(let placement):
            text = "Placement: " + placement
        case .interstitialDidClick(let placement):
            text = "Placement: " + placement
        case .interstitialDidDismiss(let placement):
            text = "Placement: " + placement
        case .interstitialDidShow(let placement, let impressionData):
            text = "Placement: " + placement + ", impression: " + impressionData.text
        case .interstitialDidFailToShow(let placement, let error, let impressionData):
            text = "Placement: " + placement + ", error: " + error.localizedDescription + ", impression: " + impressionData.text
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        return Image(systemName: "arrow.down")
    }
    
    var accentColor: Color {
        return .purple
    }
}


extension BNFYBRewardedPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .rewardedWillRequest:
            return Text("ad will request")
        case .rewardedIsAvailable:
            return Text("ad is available")
        case .rewardedDidFailToShow:
            return Text("ad did fail to show")
        case .rewardedIsUnavailable:
            return Text("ad is unavailable")
        case .rewardedDidShow:
            return Text("ad did show")
        case .rewardedDidClick:
            return Text("ad did click")
        case .rewardedDidDismiss:
            return Text("ad did dismiss")
        case .rewardedDidComplete(_, let userRewarded):
            return Text("ad did complete. ") + Text(userRewarded ? "User was rewarded" : "User wasn't rewared").bold()
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .rewardedWillRequest(let placement):
            text = "Placement: " + placement
        case .rewardedIsAvailable(let placement):
            text = "Placement: " + placement
        case .rewardedIsUnavailable(let placement):
            text = "Placement: " + placement
        case .rewardedDidClick(let placement):
            text = "Placement: " + placement
        case .rewardedDidDismiss(let placement):
            text = "Placement: " + placement
        case .rewardedDidComplete(let placement, _):
            text = "Placement: " + placement
        case .rewardedDidShow(let placement, let impressionData):
            text = "Placement: " + placement + ", impression: " + impressionData.text
        case .rewardedDidFailToShow(let placement, let error, let impressionData):
            text = "Placement: " + placement + ", error: " + error.localizedDescription + ", impression: " + impressionData.text
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        switch self {
        case .rewardedDidComplete: return Image(systemName: "star")
        default: return Image(systemName: "arrow.down")
        }
    }
    
    var accentColor: Color {
        return .blue
    }
}


extension BNFYBBannerPublisher.NoViewEvent: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .bannerWillRequest:
            return Text("ad will request")
        case .bannerDidLoad:
            return Text("ad did load")
        case .bannerDidShow:
            return Text("ad did show")
        case .bannerDidFailToLoad:
            return Text("ad did fail to load")
        case .bannerDidClick:
            return Text("ad did click")
        case .bannerWillLeaveApplication:
            return Text("ad will leave application")
        case .bannerWillPresentModalView:
            return Text("ad will present modal view")
        case .bannerDidDismissModalView:
            return Text("ad did dimiss modal view")
        case .bannerDidResizeToFrame(_ , let frame):
            return Text("ad did resize to frame: ") + Text(frame.debugDescription).bold()
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .bannerWillRequest(let placement):
            text = "Placement: " + placement
        case .bannerDidLoad(let placement):
            text = "Placement: " + placement
        case .bannerDidShow(let placement, let ad):
            text = "Placement: " + placement + ", ad: " + ad.text
        case .bannerDidFailToLoad(let placement, let error):
            text = "Placement: " + placement + ", error: " + error.localizedDescription
        case .bannerDidClick(let placement):
            text = "Placement: " + placement
        case .bannerWillLeaveApplication(let placement):
            text = "Placement: " + placement
        case .bannerWillPresentModalView(let placement):
            text = "Placement: " + placement
        case .bannerDidDismissModalView(let placement):
            text = "Placement: " + placement
        case .bannerDidResizeToFrame(let placement, _):
            text = "Placement: " + placement
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        switch self {
        case .bannerWillLeaveApplication, .bannerWillPresentModalView, .bannerDidDismissModalView: return Image(systemName: "bolt.shield")
        default: return Image(systemName: "arrow.down")
        }
    }
    
    var accentColor: Color {
        return .pink
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
        formatter.locale = Locale(identifier: "en_US")

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
