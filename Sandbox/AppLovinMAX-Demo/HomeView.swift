//
//  AdListView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import SwiftUI


struct HomeView: View {
    @State var resolution: Resolution = .default
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Ads")) {
                    NavigationLink(
                        "Interstitial",
                        destination: InterstitialView()
                    )
                    NavigationLink(
                        "Rewarded Ad",
                        destination: RewardedAdView()
                    )
                    NavigationLink(
                        "Banner",
                        destination: BannerView()
                    )
                    NavigationLink(
                        "MREC",
                        destination: MRECView()
                    )
                }
                
                Section(header: Text("Resolution")) {
                    ForEach(Resolution.allCases, id: \.self) { resolution in
                        Button(action: {
                            withAnimation {
                                self.resolution = resolution
                            }
                        }) {
                            HStack {
                                Text(resolution.rawValue)
                                Spacer()
                                if self.resolution == resolution {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onChange(of: resolution) { resolution in
                resolver = resolution.resolver
            }
            .navigationTitle("AppLovin Max + BidOn")
        }
        .navigationViewStyle(.stack)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
