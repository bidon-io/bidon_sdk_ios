//
//  HomeView.swift
//  Sandbox
//
//  Created by Bidon Team on 12.08.2022.
//

import Foundation
import SwiftUI
import Bidon
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
                        
                        ZStack {
                            AnyAdBannerWrapperView(
                                format: vm.bannerSettings.format,
                                isAutorefreshing: vm.bannerSettings.isAutorefreshing,
                                autorefreshInterval: vm.bannerSettings.autorefreshInterval,
                                pricefloor: vm.bannerSettings.pricefloor,
                                onEvent: vm.banner.receive
                            )
                            
                            if vm.isBannerLoading {
                                ProgressView()
                            }
                        }
                        .frame(height: vm.bannerHeight)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(title)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var title: Text {
        let mediation: String
        
        switch AdServiceProvider.shared.service.mediation {
        case .appodeal: mediation = "Appodeal + "
        case .none: mediation = "Raw "
        }
        
        return Text(mediation + "Bidon v\(BidonSdk.sdkVersion)")
    }
}


final class HomeViewModel: ObservableObject {
    struct BannerSettings {
        var format: AdBannerWrapperFormat
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
