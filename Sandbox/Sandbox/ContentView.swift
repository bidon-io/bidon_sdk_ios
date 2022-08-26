//
//  ContentView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 04.08.2022.
//

import SwiftUI
import BidOn


struct ContentView: View {
    @EnvironmentObject var app: AppDelegate
    
    var body: some View {
        if app.isInitialized {
            HomeView()
        } else {
            LogoProgressView()
                .transition(
                    .asymmetric(
                        insertion: .identity,
                        removal: .scale(scale: 1.2).combined(with: .opacity)
                    )
                )
        }
    }
}


fileprivate struct LogoProgressView: View {
    let font = Font.system(
        size: 24,
        weight: .heavy,
        design: .monospaced
    )
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        if #available(iOS 15, *) {
            content
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .pink, .red],
                        startPoint: isAnimating ? .bottomLeading : .topTrailing,
                        endPoint: isAnimating ? .topTrailing : .bottomLeading
                    )
                )
        } else {
            content
                .foregroundColor(.red)
        }
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            if isAnimating {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 32))
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 32))
                    .transition(.scale.combined(with: .opacity))
            }
            
            ZStack {
                Text("BidOn")
                    .font(font)
                    .offset(x: 1.5, y: 1.5)
                Text("BidOn")
                    .foregroundColor(.white)
                    .font(font)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.25).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
