//
//  ImpressionRequestBuilder.swift
//  Bidon
//
//  Created by Bidon Team on 31.08.2022.
//

import Foundation


protocol ImpressionRequestBuilder: AdTypeContextRequestBuilder {
    var imp: ImpressionModel { get }
    var route: Route { get }

    @discardableResult
    func withImpression(_ impression: Impression) -> Self

    @discardableResult
    func withPath(_ path: Route) -> Self

    init()
}


class BaseImpressionRequestBuilder<Context: AdTypeContext>: BaseRequestBuilder, ImpressionRequestBuilder {
    private(set) var context: Context!
    private(set) var impression: Impression!

    private var path: Route!

    var route: Route { .complex(.adType(adType), path) }

    var imp: ImpressionModel { fatalError("BaseImpressionRequestBuilder doesn't provide imp") }
    var adType: AdType { context.adType }

    @discardableResult
    func withImpression(_ impression: Impression) -> Self {
        self.impression = impression
        return self
    }

    @discardableResult
    func withPath(_ path: Route) -> Self {
        self.path = path
        return self
    }

    @discardableResult
    func withAdTypeContext(_ context: Context) -> Self {
        self.context = context
        return self
    }

    required override init() {
        super.init()
    }
}
