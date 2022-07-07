//
//  InterstitialView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//
import Foundation
import SwiftUI
import AppLovinDecorator
import MobileAdvertising


struct InterstitialView: View {
    static private let offset: CGFloat = 154
    
    @StateObject var vm = InterstitialViewModel()
    
    @State private var offset: CGFloat = InterstitialView.offset
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List(vm.events) { event in
                EventView(event: event)
            }
            .listStyle(.plain)
            .padding(.bottom, 64)
            
            VStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary)
                    .frame(width: 32, height: 4)
                    .padding(.top)
                HStack(spacing: 10) {
                    Button(action: {
                        vm.state.isReady ? vm.present() : vm.load()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(vm.state.color)
                                .frame(height: 44)
                            Text(vm.state.text)
                                .bold()
                        }
                    }
                    .foregroundColor(.white)
                    .disabled(vm.state.disabled)
                    
                    if vm.state.isAnimating {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    
                    if vm.state.isFailed {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ad Unit Identifier".uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("", text: $vm.adUnitIdentifier)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                }
                .padding()
                .padding(.bottom, 64)
            }
            .background(
                RoundedCorners(tl: 20, tr: 20)
            )
            .frame(maxWidth: .infinity)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        withAnimation(.interactiveSpring())  {
                            offset = max(0, min(gesture.translation.height, InterstitialView.offset))
                        }
                    }
                    .onEnded { _ in
                        if offset > 50 {
                            withAnimation { offset = InterstitialView.offset }
                        } else {
                            withAnimation { offset = 0 }
                        }
                    }
            )
        }
        .navigationTitle("Interstitial Ad")
        .edgesIgnoringSafeArea(.bottom)
    }
}


fileprivate struct EventView: View {
    var event: InterstitialViewModel.Event
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.value.title)
                    .foregroundColor(.primary)
                Text(event.value.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                Image(systemName: event.value.systemImageName)
                Text(EventView.formatter.string(from: event.time))
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }
}


struct InterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        InterstitialView()
    }
}


private extension InterstitialViewModel.State {
    var text: String {
        switch self {
        case .idle, .failed: return "Load"
        case .loading: return "Loading"
        default: return "Present"
        }
    }
    
    var color: Color {
        switch self {
        case .idle: return .blue
        case .ready: return .green
        case .failed: return .red
        default: return .gray
        }
    }
    
    var disabled: Bool {
        switch self {
        case .loading, .presenting: return true
        default: return false
        }
    }
    
    var isAnimating: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    var isFailed: Bool {
        switch self {
        case .failed: return true
        default: return false
        }
    }
    
    var isReady: Bool {
        switch self {
        case .ready: return true
        default: return false
        }
    }
}


private extension BNMAInterstitialAd.Event {
    var title: String {
        switch self {
        case .didStartAuction: return "Auction has been started"
        case .didStartAuctionRound(let id, _): return "Auction round \(id) has been started"
        case .didCompleteAuctionRound(let id): return "Auction round \(id) did complete"
        case .didCompleteAuction: return "Auction is completed"
        case .didLoad: return "Ad did loaded"
        case .didReceive: return "Did receive ad"
        case .didFail: return "Auction has been failed"
        case .didDisplay: return "Ad is presenting"
        case .didPay: return "Ad revenue is received"
        case .didHide: return "Ad did hide"
        case .didClick: return "Ad has been clicked"
        case .didDisplayFail: return "Display did fail"
        case .didGenerateCreativeId: return "Did generated creative id"
        }
    }
    
    var subtitle: String {
        switch self {
        case .didStartAuction: return ""
        case .didStartAuctionRound(_, let pricefloor): return "Pricefloor \(priceFormatter.string(from: pricefloor as NSNumber) ?? "-")"
        case .didCompleteAuctionRound: return ""
        case .didCompleteAuction: return ""
        case .didPay(let ad): return ad.text
        case .didHide(let ad): return ad.text
        case .didClick(let ad): return ad.text
        case .didLoad(let ad): return ad.text
        case .didReceive(let ad): return ad.text
        case .didDisplay(ad: let ad): return ad.text
        case .didGenerateCreativeId(let id, let ad): return "CID: \(id), \(ad)"
        case .didDisplayFail(_, let error): return error.localizedDescription
        case .didFail(_, let error): return error.localizedDescription
        }
    }
    
    var systemImageName: String {
        switch self {
        case .didStartAuction, .didCompleteAuction, .didStartAuctionRound, .didCompleteAuctionRound: return "bolt"
        case .didReceive: return "cart"
        case .didGenerateCreativeId: return "magnifyingglass"
        case .didPay: return "banknote"
        default: return "arrow.down"
        }
    }
}


private let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .currency
    return formatter
}()


private extension Ad {
    var text: String {
        "Ad #\(id) from \(dsp), price: \(priceFormatter.string(from: price as NSNumber) ?? "-")"
    }
}
