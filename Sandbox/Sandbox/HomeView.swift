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
        VStack {
            Button(action: vm.load) {
                HStack {
                    Text("Load")
                    if vm.isLoading {
                        ProgressView()
                    }
                }
                
            }
            
            Button(action: vm.show) {
                Text("Show")
            }
        }
    }
}


final class HomeViewModel: ObservableObject, FullscreenAdDelegate {
    func fullscreenAd(_ fullscreenAd: FullscreenAd, willPresentAd ad: Ad) {
        
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAd, didFailToPresentAd error: Error) {
        
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAd, didDismissAd ad: Ad) {
        
    }
    
    func adObject(_ adObject: AdObject, didLoadAd ad: Ad) {
        withAnimation { [unowned self] in
            self.isLoading = false
        }
    }
    
    func adObject(_ adObject: AdObject, didFailToLoadAd error: Error) {
        withAnimation { [unowned self] in
            self.isLoading = false
        }
    }
    
    @Published var isLoading: Bool = false
    
    private lazy var interstitial: Interstitial = {
        let interstitial = Interstitial()
        interstitial.delegate = self
        return interstitial
    }()
    
    func load() {
        withAnimation { [unowned self] in
            self.isLoading = true
        }
        interstitial.loadAd()
    }
    
    func show() {
        interstitial.show(from: UIApplication.shared.bd.topViewContoller!)
    }
}
