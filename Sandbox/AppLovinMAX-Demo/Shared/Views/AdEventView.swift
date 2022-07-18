//
//  AdEventView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI


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
                model.event.subtitle
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                model.event.image
                    .foregroundColor(model.event.accentColor)
                Text(AdEventView.formatter.string(from: model.time))
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
