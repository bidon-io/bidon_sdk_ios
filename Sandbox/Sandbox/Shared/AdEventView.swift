//
//  AdEventView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 26.08.2022.
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
                HStack {
                    Text(model.adType.title)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                    
                    Image(systemName: model.bage)
                        .foregroundColor(model.color)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Text(model.title)
                    .foregroundColor(.primary)
                
                Text(model.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                Spacer()
                Text(AdEventView.formatter.string(from: model.date))
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
