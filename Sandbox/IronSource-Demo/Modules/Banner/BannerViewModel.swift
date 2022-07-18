//
//  BannerViewModel.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import IronSource
import IronSourceDecorator
import Combine
import SwiftUI


enum BannerFormat: String, CaseIterable {
    case banner = "Banner"
    case rectangle = "Rectangle"
    
    var size: ISBannerSize {
        switch self {
        case .banner:
            return ISBannerSize(description: kSizeBanner, width: 320, height: 50)
        case .rectangle:
            return ISBannerSize(description: kSizeRectangle, width: 300, height: 250)
        }
    }
}


final class BannerViewModel: ObservableObject {
    private typealias AuctionEvent = BNISAuctionPublisher.Event

    @Published var events: [AdEventModel] = []
    @Published var format: BannerFormat = .banner
    @Published var isPresented: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        subscribe()
    }
    
    func subscribe() {
        Publishers.MergeMany([
            IronSource
                .bid
                .auctionBannerPublisher
                .map { AdEventModel(adType: .banner, event: $0) }
                .eraseToAnyPublisher(),
            IronSource
                .bid
                .levelPlayBannerPublisher
                .map { AdEventModel(adType: .banner, event: $0) }
                .eraseToAnyPublisher()
        ])
        .receive(on: DispatchQueue.main)
        .sink { event in
            withAnimation { [weak self] in
                self?.events.append(event)
            }
        }
        .store(in: &cancellables)
        
        $events
            .compactMap { $0.last?.event as? AuctionEvent }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                var isLoading = self.isLoading
                switch event {
                case .didStartAuction:
                    isLoading = true
                case .didCompleteAuction:
                    isLoading = false
                default: break
                }
                
                withAnimation { [unowned self] in
                    self.isLoading = isLoading
                }
            }
            .store(in: &cancellables)
    }
}
