//
//  AdType.swift
//  Bidon
//
//  Created by Bidon Team on 02.06.2023.
//

import Foundation


protocol AdTypeContextRequestBuilder: BaseRequestBuilder {
    associatedtype Context: AdTypeContext

    @discardableResult
    func withAdTypeContext(_ context: Context) -> Self
}


protocol AdTypeContext {
    associatedtype DemandProviderType: DemandProvider
    associatedtype AuctionRequestBuilderType: AuctionRequestBuilder where AuctionRequestBuilderType.Context == Self
    associatedtype StatisticRequestBuilderType: StatisticRequestBuilder where StatisticRequestBuilderType.Context == Self
    associatedtype ImpressionRequestBuilderType: ImpressionRequestBuilder where ImpressionRequestBuilderType.Context == Self
    associatedtype NotificationRequestBuilderType: NotificationRequestBuilder where NotificationRequestBuilderType.Context == Self

    var adType: AdType { get }

    func auctionRequest(build: (AuctionRequestBuilderType) -> ()) -> AuctionRequest
    func impressionRequest(build: (ImpressionRequestBuilderType) -> ()) -> ImpressionRequest
    func statisticRequest(build: (StatisticRequestBuilderType) -> ()) -> StatisticRequest
    func notificationRequest(build: (NotificationRequestBuilderType) -> ()) -> NotificationRequest

    func fullscreenAdapters() -> [AnyDemandSourceAdapter<Self.DemandProviderType>]
    func adViewAdapters(viewContext: AdViewContext) -> [AnyDemandSourceAdapter<Self.DemandProviderType>]
}
