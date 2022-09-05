//
//  OverlayProgressView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation
import SwiftUI


struct OverlayProgressView: View {
    let font = Font.system(
        size: 24,
        weight: .heavy,
        design: .monospaced
    )
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
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


struct OverlayPrgoressViewModifier: ViewModifier {
    var isAnimating: Bool
    
    func body(content: Content) -> some View {
        return content
            .overlay(overlay)
    }
    
    private var overlay: some View {
        if isAnimating {
            return AnyView(OverlayProgressView())
        } else {
            return AnyView(EmptyView())
        }
    }
}


extension View {
    func progressOverlay(_ isAnimating: Bool) -> some View {
        return modifier(OverlayPrgoressViewModifier(isAnimating: isAnimating))
    }
}
