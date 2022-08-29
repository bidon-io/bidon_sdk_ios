//
//  HomeView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation
import SwiftUI
import BidOn
import Combine


struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    List {
                        InterstitialSection()
                        RewardedAdSection()
                        BannerAdSection()
                            .environmentObject(vm.banner)
                    }
                    
                    if vm.isBannerPresented {
                        Divider()
                            .padding(.bottom)
                        
                        BannerView(
                            format: vm.bannerSettings.format,
                            isAutorefreshing: vm.bannerSettings.isAutorefreshing,
                            autorefreshInterval: vm.bannerSettings.autorefreshInterval
                        )
                        .frame(height: vm.bannerHeight)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("BidOn v\(BidOnSdk.sdkVersion)")
            }
        }
    }
}


final class HomeViewModel: ObservableObject {
    struct BannerSettings {
        var format: AdViewFormat
        var isAutorefreshing: Bool
        var autorefreshInterval: TimeInterval
    }
    
    @Published var banner = BannerAdSectionViewModel()
    
    @Published var isBannerPresented: Bool = false
    @Published var bannerHeight: CGFloat = 0
    @Published var bannerSettings = BannerSettings(
        format: .banner,
        isAutorefreshing: true,
        autorefreshInterval: 15
    )
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    func subscribe() {
        banner.$isPresented.sink { [unowned self] in
            self.isBannerPresented = $0
        }
        .store(in: &cancellables)
        
        banner.$format.map { $0.preferredSize.height }.sink { height in
            withAnimation { [unowned self] in
                self.bannerHeight = height
            }
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            banner.$format,
            banner.$isAutorefreshing,
            banner.$autorefreshInterval
        )
        .sink { [unowned self] in
            self.bannerSettings = BannerSettings(
                format: $0.0,
                isAutorefreshing: $0.1,
                autorefreshInterval: $0.2
            )
        }
        .store(in: &cancellables)
    }
}
