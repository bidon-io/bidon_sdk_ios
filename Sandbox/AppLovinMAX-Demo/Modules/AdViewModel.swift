//
//  AdViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import Combine
import SwiftUI


class AdViewModel: ObservableObject {
    @Published var adUnitIdentifier: String = "YOUR_AD_UNIT_ID"
    @Published var events: [AdEventModel] = []
    @Published var state: AdState = .idle
    
    private var cancellables = Set<AnyCancellable>()

    func subscribe(_ publisher: AnyPublisher<AdEvent, Never>) {
        cancellables.removeAll()
        publisher.receive(on: DispatchQueue.main).sink { [unowned self] event in
            var state = self.state
                        
            switch event {
            case .didStartAuction: state = .loading
            case .didFail: state = .failed
            case .didDisplay: state = .presenting
            case .didHide: state = .idle
            case .didLoad: state = .ready
            default: break
            }
            
            let model = AdEventModel(event: event)
            
            withAnimation { [unowned self] in
                if self.state != state {
                    self.state = state
                }
                
                self.events.append(model)
            }
        }
        .store(in: &cancellables)
    }
}
