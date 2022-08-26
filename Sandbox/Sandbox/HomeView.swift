//
//  HomeView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 12.08.2022.
//

import Foundation
import SwiftUI
import BidOn


struct HomeView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var bannerHeight: CGFloat {
        return sizeClass == .compact ? 50 : 90
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    List {
                        InterstitialSection()
                        RewardedAdSection()
                    }
                    
                    BannerView()
                        .frame(height: bannerHeight)
                }
                .navigationTitle("BidOn v\(BidOnSdk.sdkVersion)")
            }
        }
    }
}


