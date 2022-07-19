//
//  AdEvent.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising
import AppLovinDecorator


protocol AdEventViewRepresentable {
    var title: Text { get }
    var subtitle: Text { get }
    var image: Image { get }
    var accentColor: Color { get }
}


struct AdEventModel: Identifiable {
    var id: UUID = UUID()
    var time: Date = Date()
    var event: AdEventViewRepresentable
}


extension BNMAAdPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didLoad:
            return Text("Ad is ready to show")
        case .didFailToLoadAd:
            return Text("No ad is ready for show")
        case .didFailToDisplay:
            return Text("Ad is failed to display")
        case .didDisplay:
            return Text("The ad was shown")
        case .didHide:
            return Text("The ad did hide")
        case .didClick:
            return Text("The Ad has been clicked")
        }
    }
    
    var subtitle: Text {
        let text: String
        
        switch self {
        case .didHide(let ad):
            text = "Ad: " + ad.text
        case .didClick(let ad):
            text = "Ad: " + ad.text
        case .didLoad(let ad):
            text = "Ad: " + ad.text
        case .didDisplay(ad: let ad):
            text = "Ad: " + ad.text
        case .didFailToLoadAd(adUnitIdentifier: let adUnitIdentifier, error: let error):
            text = "Ad Unit ID: " + adUnitIdentifier + ", error: " + error.localizedDescription
        case .didFailToDisplay(ad: let ad, error: let error):
            text = "Ad: " + ad.text + ", error: " + error.localizedDescription
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        return Image(systemName: "arrow.down")
    }
    
    var accentColor: Color {
        return .primary
    }
}


extension BNMARewardedAdPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didLoad:
            return Text("Ad is ready to show")
        case .didFailToLoadAd:
            return Text("No ad is ready for show")
        case .didFailToDisplay:
            return Text("Ad is failed to display")
        case .didDisplay:
            return Text("The ad was shown")
        case .didHide:
            return Text("The ad did hide")
        case .didClick:
            return Text("The Ad has been clicked")
        case .didRewardUser(_, let reward):
            return Text("The ad did receive reward: ") + Text("\"\(reward.amount)\"").bold() + Text(" of ") + Text(reward.label).bold()
        }
    }
    
    var subtitle: Text {
        let text: String
        
        switch self {
        case .didHide(let ad):
            text = "Ad: " + ad.text
        case .didClick(let ad):
            text = "Ad: " + ad.text
        case .didLoad(let ad):
            text = "Ad: " + ad.text
        case .didDisplay(ad: let ad):
            text = "Ad: " + ad.text
        case .didRewardUser(let ad, _):
            text = "Ad: " + ad.text
        case .didFailToLoadAd(adUnitIdentifier: let adUnitIdentifier, error: let error):
            text = "Ad Unit ID: " + adUnitIdentifier + ", error: " + error.localizedDescription
        case .didFailToDisplay(ad: let ad, error: let error):
            text = "Ad: " + ad.text + ", error: " + error.localizedDescription
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


extension BNMAAdViewAdPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didLoad:
            return Text("Ad is ready to show")
        case .didFailToLoadAd:
            return Text("No ad is ready for show")
        case .didFailToDisplay:
            return Text("Ad is failed to display")
        case .didDisplay:
            return Text("The ad was shown")
        case .didHide:
            return Text("The ad did hide")
        case .didClick:
            return Text("The Ad has been clicked")
        case .didExpand:
            return Text("The ad did expand")
        case .didCollapse:
            return Text("The ad did expand")
        }
    }
    
    var subtitle: Text {
        let text: String
        
        switch self {
        case .didHide(let ad):
            text = "Ad: " + ad.text
        case .didClick(let ad):
            text = "Ad: " + ad.text
        case .didLoad(let ad):
            text = "Ad: " + ad.text
        case .didDisplay(ad: let ad):
            text = "Ad: " + ad.text
        case .didExpand(ad: let ad):
            text = "Ad: " + ad.text
        case .didCollapse(ad: let ad):
            text = "Ad: " + ad.text
        case .didFailToLoadAd(adUnitIdentifier: let adUnitIdentifier, error: let error):
            text = "Ad Unit ID: " + adUnitIdentifier + ", error: " + error.localizedDescription
        case .didFailToDisplay(ad: let ad, error: let error):
            text = "Ad: " + ad.text + ", error: " + error.localizedDescription
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


extension BNMAuctionPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didStartAuction:
            return Text("The auction has been started")
        case .didStartAuctionRound(let id, _):
            return Text("A round of auction ") + Text("\"\(id)\"").bold() + Text(" has been launched")
        case .didCompleteAuctionRound(let id):
            return Text("Auction round ") + Text("\"\(id)\"").bold() + Text(" has been ended")
        case .didCompleteAuction:
            return Text("The auction has ended")
        case .didReceiveAd:
            return Text("An ad was received")
        }
    }
    
    var subtitle: Text {
        let text: String
        
        switch self {
        case .didStartAuctionRound(_, let pricefloor):
            text = "Pricefloor: \(pricefloor.pretty)"
        case .didReceiveAd(let ad):
            text = ad.text
        case .didCompleteAuction(let ad):
            text = ad.map { "Winner: \($0.text)" } ?? "No winner"
        default:
            text = ""
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


extension BNMAAdRevenuePublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didPayRevenue:
            return Text("Revenue was received from an ad")
        }
    }
    
    var subtitle: Text {
        let text: String
        
        switch self {
        case .didPayRevenue(let ad):
            text = ad.text
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        return Image(systemName: "banknote")
    }
    
    var accentColor: Color {
        return .green
    }
}


extension BNMAAdReviewPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didGenerateCreativeIdentifier(let creativeIdentifier, _):
            return Text("Ad did generate creative identifier: ") + Text(creativeIdentifier).bold()
        }
    }
    
    var subtitle: Text {
        let text: String
        
        switch self {
        case .didGenerateCreativeIdentifier(_, let ad):
            text = ad.text
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        return Image(systemName: "magnifyingglass")
    }
    
    var accentColor: Color {
        return .green
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
        "Ad #\(id.prefix(3))... from \(networkName), price: \(price.pretty)"
    }
}

