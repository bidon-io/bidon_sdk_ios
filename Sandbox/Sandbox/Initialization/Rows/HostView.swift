//
//  HostView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation
import SwiftUI


struct HostView: View {
    struct Model: Identifiable, Codable, Equatable {
        var id: String { name }
        
        var name: String
        var baseURL: String
    }
    
    var host: Model
    @Binding var selected: Model
    
    var body: some View {
        Button(action: {
            withAnimation {
                selected = host
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(host.name)
                        .foregroundColor(.primary)
                    Text(host.baseURL)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if selected == host {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

