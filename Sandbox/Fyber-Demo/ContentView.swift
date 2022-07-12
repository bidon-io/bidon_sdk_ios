//
//  ContentView.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 28.06.2022.
//

import SwiftUI
import Combine


struct ContentView: View {
    @State var isPresented: Bool = false
    
    var body: some View {
        if isPresented {
            HomeView()
        } else {
            LogoProgressView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        withAnimation { isPresented = true }
                    }
                }
        }
    }
}


fileprivate struct LogoProgressView: View {
    var body: some View {
        if #available(iOS 15, *) {
            content.foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple, .red],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
        } else {
            content.foregroundColor(.red)
        }
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .imageScale(.large)
            ZStack {
                Text("Fyber ❤️ Bidon")
                    .font(Font.system(
                        size: 16,
                        weight: .heavy,
                        design: .monospaced
                    ))
                    .offset(x: 0.5, y: 0.5)
                Text("Fyber ❤️ Bidon")
                    .foregroundColor(.primary)
                    .font(Font.system(
                        size: 16,
                        weight: .heavy,
                        design: .monospaced
                    ))
            }
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
