//
//  AdEventModel.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import SwiftUI
import BidOn
import BidOnDecoratorIronSource


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


extension BNLevelPlayRewardedVideoPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .hasAvailableAd:
            text = Text("has available ad")
        case .hasNoAvailableAd:
            text = Text("has no available ad")
        case .didReceiveReward:
            return Text("ad did receive reward")
        case .didFailToShowWithError:
            return Text("ad did fail to show")
        case .didOpen:
            return Text("ad did open")
        case .didClose:
            return Text("ad did close")
        case .didClick:
            return Text("ad did click")
        }
        
        return Text("(level play)").italic() + Text(" ") + text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .hasAvailableAd(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didReceiveReward(let placement, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " placement: " + (placement?.debugDescription ?? "-")
        case .didFailToShowWithError(let error, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " error: " + (error?.localizedDescription ?? "-")
        case .didOpen(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClose(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClick(let placement, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " placement: " + (placement?.debugDescription ?? "-")
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "gamecontroller")
    }
    
    var accentColor: Color {
        .red
    }
}


extension BNLevelPlayInterstitialPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .didLoad:
            text = Text("ad did load")
        case .didFailToLoadWithError:
            text = Text("ad did fail to load")
        case .didFailToShowWithError:
            text = Text("ad did fail to show")
        case .didShow:
            text = Text("ad did show")
        case .didOpen:
            text = Text("ad did open")
        case .didClose:
            text = Text("ad did close")
        case .didClick:
            text = Text("ad did click")
        }
        
        return Text("(level play)").italic() + Text(" ") + text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didLoad(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didFailToLoadWithError(let error):
            text = "Error: " + (error?.localizedDescription ?? "-")
        case .didFailToShowWithError(let error, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " error: " + (error?.localizedDescription ?? "-")
        case .didOpen(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClose(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didShow(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClick(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "gamecontroller")
    }
    
    var accentColor: Color {
        .red
    }
}


extension BNLevelPlayBannerPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .didLoad:
            text = Text("ad did load")
        case .didFailToLoadWithError:
            text = Text("ad did fail to load")
        case .didPresentScreen:
            text = Text("ad did present screen")
        case .didDismissScreen:
            text = Text("ad did dismiss screen")
        case .didLeaveApplication:
            text = Text("ad did leave applcation")
        case .didClick:
            text = Text("ad did click")
        }
        
        return Text("(level play)").italic() + Text(" ") + text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didFailToLoadWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "gamecontroller")
    }
    
    var accentColor: Color {
        .red
    }
}


extension ISRewardedVideoPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .hasChangedAvailability(let available):
            return Text("ad did change availability. ") + Text(available ? "ad is available" : "ad is not available").bold()
        case .didReceiveReward:
            return Text("ad did receive reward")
        case .didFailToShowWithError:
            return Text("ad did fail to show")
        case .didOpen:
            return Text("ad did open")
        case .didClose:
            return Text("ad did close")
        case .didStart:
            return Text("ad did start")
        case .didEnd:
            return Text("ad did end")
        case .didClick:
            return Text("ad did click")
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didReceiveReward(let placementInfo):
            text = "Placement info: \(placementInfo?.debugDescription ?? "-")"
        case .didClick(let placementInfo):
            text = "Placement info: \(placementInfo?.debugDescription ?? "-")"
        case .didFailToShowWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "arrow.down")
    }
    
    var accentColor: Color {
        .blue
    }
}


extension ISInterstitialPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didLoad:
            return Text("ad did load")
        case .didFailToLoadWithError:
            return Text("ad did fail to load")
        case .didFailToShowWithError:
            return Text("ad did fail to show")
        case .didOpen:
            return Text("ad did open")
        case .didClose:
            return Text("ad did close")
        case .didStart:
            return Text("ad did start")
        case .didClick:
            return Text("ad did click")
        case .didShow:
            return Text("ad did show")
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didFailToLoadWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
        case .didFailToShowWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "arrow.down")
    }
    
    var accentColor: Color {
        .blue
    }
}


extension BNISAuctionPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .didStartAuction:
            text = Text("ad did start auction")
        case .didStartAuctionRound(let round, _):
            text = Text("ad did start auction round ") + Text("\"\(round)\"").bold()
        case .didReceiveAd:
            text = Text("ad did receive ad")
        case .didCompleteAuctionRound(let round):
            text = Text("ad did complete auction round ") + Text("\"\(round)\"").bold()
        case .didCompleteAuction:
            text = Text("ad did complete auction")
        }
        
        return text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didStartAuctionRound(_, let pricefloor):
            text = "Pricefloor: \(pricefloor.pretty)"
        case .didReceiveAd(let ad):
            text = "Ad: " + ad.text
        case .didCompleteAuction(let ad):
            text = ad.map { "Winner: " + $0.text } ?? "No winner"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "bolt")
    }
    
    var accentColor: Color {
        .orange
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
        "Ad #\(id.prefix(3))... from \(networkName), price: \(price.pretty)"
    }
}
