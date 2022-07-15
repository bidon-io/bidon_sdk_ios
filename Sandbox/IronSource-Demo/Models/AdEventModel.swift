import Foundation
import SwiftUI
import MobileAdvertising


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
        "Ad #\(id.prefix(3))... from \(dsp), price: \(price.pretty)"
    }
}
