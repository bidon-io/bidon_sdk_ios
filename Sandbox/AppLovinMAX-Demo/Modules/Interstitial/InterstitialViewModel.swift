//
//  InterstitialViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import Combine
import AppLovinDecorator
import AppLovinSDK
import SwiftUI


final class InterstitialViewModel: ObservableObject {
    struct Event: Identifiable {
        var id: UUID = UUID()
        var time: Date = Date()
        var value: BNMAInterstitialAd.Event
    }
    
    enum State {
        case idle
        case loading
        case ready
        case presenting
        case failed
    }
    
    @Published var adUnitIdentifier: String = "YOUR_AD_UNIT_ID"
    @Published var events: [Event] = []
    @Published var state: State = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    private var interstitial: BNMAInterstitialAd? {
        didSet {
            guard let interstitial = interstitial else { return }
            cancellables.removeAll()
            subscribe(interstitial)
        }
    }
    
    func subscribe(_ interstitial: BNMAInterstitialAd) {
        interstitial.publisher.receive(on: DispatchQueue.main).sink { [unowned self] event in
            var state = self.state
            
            switch event {
            case .didFail: state = .failed
            case .didDisplay: state = .presenting
            case .didHide: state = .idle
            case .didLoad: state = .ready
            default: break
            }
            
            let model = Event(value: event)
            
            withAnimation { [unowned self] in
                if self.state != state {
                    self.state = state
                }
                
                self.events.append(model)
            }
        }
        .store(in: &cancellables)
    }
    
    func load() {
        let interstital = BNMAInterstitialAd(
            adUnitIdentifier: adUnitIdentifier,
            sdk: applovin
        )
    
        self.interstitial = interstital
        self.interstitial?.loadAd()
        
        withAnimation { [unowned self] in
            self.state = .loading
        }
    }
    
    func present() {
        guard let interstitial = interstitial else { return }
        interstitial.show()
    }
}
