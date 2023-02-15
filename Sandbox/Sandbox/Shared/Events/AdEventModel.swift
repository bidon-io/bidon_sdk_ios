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


extension AdEventModel {
    init(_ event: InterstitialPublisher.Event) {
        date = Date()
        adType = .interstitial
        
        switch event {
        case .didLoadAd(let ad):
            title = "Did load ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didFailToLoadAd(let error):
            title = "Did fail to load ad"
            subtitle = error.localizedDescription
            bage = "staroflife"
            color = .red
        case .didFailToPresentAd(let error):
            title = "Did fail to present ad"
            subtitle = error.localizedDescription
            bage = "staroflife"
            color = .red
        case .willPresentAd(let ad):
            title = "Will present ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didDismissAd(let ad):
            title = "Did dismiss ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didRecordClick(let ad):
            title = "Did record click"
            subtitle = ad.text
            bage = "star"
            color = .accentColor
        case .didRecordImpression(let ad):
            title = "Did record impression"
            subtitle = ad.text
            bage = "star"
            color = .accentColor
        case .didPayRevenue(let ad):
            title = "Did pay revenue"
            subtitle = ad.text
            bage = "dollarsign.circle"
            color = .green
        case .didStartAuction:
            title = "Did start auction"
            subtitle = ""
            bage = "suit.diamond"
            color = .purple
        case .didStartAuctionRound(let auctionRound, let pricefloor):
            title = "Did start auction round: \(auctionRound)"
            subtitle = "Pricefloor: " + pricefloor.pretty
            bage = "suit.diamond"
            color = .purple
        case .didReceiveBid(let ad):
            title = "Did receive bid"
            subtitle = ad.text
            bage = "suit.diamond"
            color = .purple
        case .didCompleteAuctionRound(let auctionRound):
            title = "Did complete auction round: \(auctionRound)"
            subtitle = ""
            bage = "suit.diamond"
            color = .purple
        case .didCompleteAuction(let winner):
            title = "Did complete auction"
            subtitle = winner.map { "Winner is \($0.text)" } ?? "No winner"
            bage = "suit.diamond"
            color = .purple
        }
    }
}


extension AdEventModel {
    init(_ event: RewardedAdPublisher.Event) {
        date = Date()
        adType = .rewardedAd
        
        switch event {
        case .didLoadAd(let ad):
            title = "Did load ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didFailToLoadAd(let error):
            title = "Did fail to load ad"
            subtitle = error.localizedDescription
            bage = "staroflife"
            color = .red
        case .didFailToPresentAd(let error):
            title = "Did fail to present ad"
            subtitle = error.localizedDescription
            bage = "staroflife"
            color = .red
        case .willPresentAd(let ad):
            title = "Will present ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didDismissAd(let ad):
            title = "Did dismiss ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didRewardUser(let reward):
            title = "Did reward user"
            subtitle = reward.text
            bage = "staroflife"
            color = .secondary
        case .didRecordClick(let ad):
            title = "Did record click"
            subtitle = ad.text
            bage = "star"
            color = .accentColor
        case .didRecordImpression(let ad):
            title = "Did record impression"
            subtitle = ad.text
            bage = "star"
            color = .accentColor
        case .didPayRevenue(let ad):
            title = "Did pay revenue"
            subtitle = ad.text
            bage = "dollarsign.circle"
            color = .green
        case .didStartAuction:
            title = "Did start auction"
            subtitle = ""
            bage = "suit.diamond"
            color = .purple
        case .didStartAuctionRound(let auctionRound, let pricefloor):
            title = "Did start auction round: \(auctionRound)"
            subtitle = "Pricefloor: " + pricefloor.pretty
            bage = "suit.diamond"
            color = .purple
        case .didReceiveBid(let ad):
            title = "Did receive bid"
            subtitle = ad.text
            bage = "suit.diamond"
            color = .purple
        case .didCompleteAuctionRound(let auctionRound):
            title = "Did complete auction round: \(auctionRound)"
            subtitle = ""
            bage = "suit.diamond"
            color = .purple
        case .didCompleteAuction(let winner):
            title = "Did complete auction"
            subtitle = winner.map { "Winner is \($0.text)" } ?? "No winner"
            bage = "suit.diamond"
            color = .purple
        }
    }
}


extension AdEventModel {
    init(_ event: BannerPublisher.Event) {
        date = Date()
        adType = .banner
        
        switch event {
        case .didLoadAd(let ad):
            title = "Did load ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didFailToLoadAd(let error):
            title = "Did fail to load ad"
            subtitle = error.localizedDescription
            bage = "staroflife"
            color = .red
        case .willPresentModalView(let ad):
            title = "Will present modal view ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didDismissModalView(let ad):
            title = "Did dismiss modal view ad"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .willLeaveApplication(let ad):
            title = "Will leave application"
            subtitle = ad.text
            bage = "staroflife"
            color = .secondary
        case .didRecordClick(let ad):
            title = "Did record click"
            subtitle = ad.text
            bage = "star"
            color = .accentColor
        case .didRecordImpression(let ad):
            title = "Did record impression"
            subtitle = ad.text
            bage = "star"
            color = .accentColor
        case .didPayRevenue(let ad):
            title = "Did pay revenue"
            subtitle = ad.text
            bage = "dollarsign.circle"
            color = .green
        case .didStartAuction:
            title = "Did start auction"
            subtitle = ""
            bage = "suit.diamond"
            color = .purple
        case .didStartAuctionRound(let auctionRound, let pricefloor):
            title = "Did start auction round: \(auctionRound)"
            subtitle = "Pricefloor: " + pricefloor.pretty
            bage = "suit.diamond"
            color = .purple
        case .didReceiveBid(let ad):
            title = "Did receive bid"
            subtitle = ad.text
            bage = "suit.diamond"
            color = .purple
        case .didCompleteAuctionRound(let auctionRound):
            title = "Did complete auction round: \(auctionRound)"
            subtitle = ""
            bage = "suit.diamond"
            color = .purple
        case .didCompleteAuction(let winner):
            title = "Did complete auction"
            subtitle = winner.map { "Winner is \($0.text)" } ?? "No winner"
            bage = "suit.diamond"
            color = .purple
        }
    }
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
        "Ad #\(id.prefix(3))... from \(networkName), price: \(price.pretty)"
    }
}


private extension Reward {
    var text: String {
        "Reward \(amount) of \(label)"
    }
}
