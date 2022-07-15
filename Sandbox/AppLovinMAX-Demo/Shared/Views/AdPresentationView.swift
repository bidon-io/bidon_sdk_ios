//
//  AdPresentationView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import SwiftUI


struct AdPresentationView<Content: View, Ad: View>: View {
    var title: String
    var events: [AdEventModel]
    var content: Content
    var ad: Ad
    
    @Binding var isAdPresented: Bool
    @State private var offset: CGFloat = 96
    
    init(
        title: String,
        events: [AdEventModel],
        isAdPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder ad: () -> Ad
    ) {
        self.title = title
        self.events = events
        self.content = content()
        self.ad = ad()
        self._isAdPresented = isAdPresented
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                GeometryReader { proxy in
                    List(events) { event in
                        AdEventView(model: event)
                    }
                    .listStyle(.plain)
                    .padding(.bottom, 110)
                    .background(Color(UIColor.systemBackground))
                    
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary)
                            .frame(width: 56, height: 6)
                            .padding(8)
                            .gesture(gesture(proxy))
                        content
                    }
                    .background(RoundedCorners(tl: 20, tr: 20))
                    .offset(y: proxy.size.height - offset)
                }
            }
            
            if isAdPresented {
                ad
            }
        }
        .navigationTitle(title)
        .background(
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
        )
    }
    
    private func gesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                withAnimation(.interactiveSpring())  {
                    offset = -gesture.translation.height
                }
            }
            .onEnded { _ in
                if offset > proxy.size.height / 2 {
                    withAnimation { offset = proxy.size.height / 4 * 3 }
                } else if offset > proxy.size.height / 4 {
                    withAnimation { offset = proxy.size.height / 3 }
                } else {
                    withAnimation { offset = 110 }
                }
            }
    }
}


struct FullscreenAdPresentationView<Content: View>: View {
    var title: String
    var events: [AdEventModel]
    var content: Content
    
    init(
        title: String,
        events: [AdEventModel],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.events = events
        self.content = content()
    }
    
    var body: some View {
        AdPresentationView(
            title: title,
            events: events,
            isAdPresented: .constant(false),
            content: { content }
        ) {
            EmptyView()
        }
    }
}

struct AdPresentationView_Previews: PreviewProvider {
    static var previews: some View {
        AdPresentationView(
            title: "Dummy",
            events: [],
            isAdPresented: .constant(true),
            content: {
                VStack {
                    Text("HEY").font(.largeTitle)
                    Toggle("Some toogle", isOn: .constant(true))
                }
                .padding()
            },
            ad: {
                Rectangle()
                    .fill(.green)
                    .frame(height: 50)
            }
        )
    }
}
