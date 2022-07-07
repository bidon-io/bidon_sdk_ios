//
//  AdEventView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI


struct AdEventModel: Identifiable {
    var id: UUID = UUID()
    var time: Date = Date()
    var event: AdEvent
}


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
                model.event.title
                    .foregroundColor(.primary)
                Text(model.event.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                Image(systemName: model.event.systemImageName)
                    .foregroundColor(model.event.accentColor)
                Text(AdEventView.formatter.string(from: model.time))
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
