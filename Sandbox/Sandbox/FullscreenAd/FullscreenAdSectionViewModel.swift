//
//  FullscreenAdSectionViewModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import Combine
import SwiftUI


final class FullscreenAdSectionViewModel: ObservableObject, AdResponder {
    enum State: Equatable {
        case idle
        case loading
        case error
        case ready
        case presenting
        case presentationError
    }
    
    @Published var state: State = .idle
    @Published var events: [AdEventModel] = []
    @Published var pricefloor: Double = 0.1
    
    private var cancellables = Set<AnyCancellable>()
    private let adType: AdType
    
    init(adType: AdType) {
        self.adType = adType
        
        subscribe()
    }
    
    @MainActor
    func load() async {
        update(.loading)
        do {
            try await adService.load(
                pricefloor: pricefloor,
                adType: adType
            )
            update(.ready)
        } catch {
            update(.error)
        }
    }
    
    @MainActor
    func show() async {
        update(.presenting)
        do {
            try await adService.show(adType: adType)
            update(.idle)
        } catch {
            update(.presentationError)
        }
    }
    
    private func update(
        _ state: State,
        animation: Animation = .default
    ) {
        withAnimation(animation) { [unowned self] in
            self.state = state
        }
    }
    
    private func subscribe() {
        adService
            .adEventPublisher(adType: adType)
            .receive(on: RunLoop.main)
            .sink { event in
                withAnimation { [unowned self] in
                    self.events.append(event)
                }
            }
            .store(in: &cancellables)
    }
}
