//
//  AdEventView.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising
import IronSourceDecorator


struct AdEventView: View {
    var model: AdEventModel
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    model.adType.title
                    model.event.image
                        .foregroundColor(model.event.accentColor)
                    Spacer()
                }
                
                model.event.title
                    .foregroundColor(.primary)
                
               model.event.subtitle
            }
            
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                Spacer()
                Text(AdEventView.formatter.string(from: model.time))
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }
}


struct AdEventView_Previews: PreviewProvider {
    typealias RewardedVideoEvent = ISRewardedVideoPublisher.Event
    
    static var previews: some View {
        List {
            AdEventView(model: .init(adType: .rewardedVideo, event: RewardedVideoEvent.didOpen))
        }
        .listStyle(PlainListStyle())
    }
}

