//
//  AdViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import Combine
import SwiftUI


class AdViewModel: ObservableObject {
    @Published var events: [AdEventModel] = []
    
    @Published private(set) var state: AdState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        $events
            .compactMap { $0.last }
            .map { $0.event }
            .sink { [unowned self] event in
                var state = self.state
                
                switch event {
                case .willRequest: state = .loading
                case .isUnavailable: state = .failed
                case .didShow: state = .presenting
                case .didDismiss: state = .idle
                case .isAvailable: state = .ready
                default: break
                }
                
                withAnimation { [unowned self] in
                    if self.state != state {
                        self.state = state
                    }
                }
            }
            .store(in: &cancellables)
    }
}

