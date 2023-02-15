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
//                        BannerAdSection()
//                            .environmentObject(vm.banner)
                    }
                    
//                    if vm.isBannerPresented {
//                        Divider()
//
//                        ZStack {
//                            BannerView(
//                                format: vm.bannerSettings.format,
//                                isAutorefreshing: vm.bannerSettings.isAutorefreshing,
//                                autorefreshInterval: vm.bannerSettings.autorefreshInterval,
//                                pricefloor: vm.bannerSettings.pricefloor,
//                                onEvent: vm.banner.receive
//                            )
//
//                            if vm.isBannerLoading {
//                               ProgressView()
//                            }
//                        }
//                        .frame(height: vm.bannerHeight)
//                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("BidOn v\(BidOnSdk.sdkVersion)")
            }
        }
        .navigationViewStyle(.stack)
    }
}


final class HomeViewModel: ObservableObject {
    struct BannerSettings {
        var format: AdViewFormat
        var isAutorefreshing: Bool
        var autorefreshInterval: TimeInterval
        var pricefloor: Price
    }
    
    @Published var banner = BannerAdSectionViewModel()
    
    @Published var isBannerPresented: Bool = false
    @Published var isBannerLoading: Bool = false
    @Published var bannerHeight: CGFloat = 0
    @Published var bannerSettings = BannerSettings(
        format: .banner,
        isAutorefreshing: false,
        autorefreshInterval: 15,
        pricefloor: 0.1
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
        
        banner.$isLoading.sink { isBannerLoading in
            withAnimation { [unowned self] in
                self.isBannerLoading = isBannerLoading
            }
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest4(
            banner.$format,
            banner.$isAutorefreshing,
            banner.$autorefreshInterval,
            banner.$pricefloor
        )
        .sink { [unowned self] in
            self.bannerSettings = BannerSettings(
                format: $0.0,
                isAutorefreshing: $0.1,
                autorefreshInterval: $0.2,
                pricefloor: $0.3
            )
        }
        .store(in: &cancellables)
    }
}
