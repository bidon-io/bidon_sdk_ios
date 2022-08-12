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
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        Text("Home, sweet home")
            .onAppear(perform: vm.appear)
    }
}


final class HomeViewModel: ObservableObject {
    private lazy var interstitial = Interstitial()
    
    func appear() {
        interstitial.loadAd()
    }
}
