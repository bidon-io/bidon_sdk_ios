//
//  AnyDemandProvider.swift
//  Bidon
//
//  Created by Bidon Team on 02.09.2022.
//

import Foundation


class AnyDemandProvider<W>: NSObject, DemandProvider {
    var delegate: DemandProviderDelegate? {
        get { _delegate() }
        set { _setDelegate(newValue) }
    }
    
    var revenueDelegate: DemandProviderRevenueDelegate? {
        get { _revenueDelegate() }
        set { _setRevenueDelegate(newValue) }
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        _fill(ad, response)
    }
    
    func notify(ad: Ad, event: AuctionEvent) {
        _notify(ad, event)
    }
    
    let wrapped: W
        
    private let _delegate: () -> DemandProviderDelegate?
    private let _setDelegate: (DemandProviderDelegate?) -> ()
    
    private let _revenueDelegate: () -> DemandProviderRevenueDelegate?
    private let _setRevenueDelegate: (DemandProviderRevenueDelegate?) -> ()
    
    private let _fill: (Ad, @escaping DemandProviderResponse) -> ()
    private let _notify: (Ad, AuctionEvent) -> ()
    
    init(_ wrapped: W) throws {
        self.wrapped = wrapped
        
        guard let wrapped = wrapped as? any DemandProvider else { throw SdkError.internalInconsistency }
        
        _delegate = { wrapped.delegate }
        _setDelegate = { wrapped.delegate = $0 }
        
        _revenueDelegate = { wrapped.revenueDelegate }
        _setRevenueDelegate = { wrapped.revenueDelegate = $0 }
        
        _fill = { wrapped._fill(ad: $0, response: $1) }
        _notify = { wrapped._notify(ad: $0, event: $1) }
    }
}


final class AnyDirectDemandProvider<W>: AnyDemandProvider<W>, DirectDemandProvider {
    private let _bid: (LineItem, @escaping DemandProviderResponse) -> ()
    
    override init(_ wrapped: W) throws {
        guard let _wrapped = wrapped as? any DirectDemandProvider else { throw SdkError.internalInconsistency }
        
        _bid = { _wrapped.bid($0, response: $1) }
        
        try super.init(wrapped)
    }
    
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        _bid(lineItem, response)
    }
}


final class AnyProgrammaticDemandProvider<W>: AnyDemandProvider<W>, ProgrammaticDemandProvider {
    private let _bid: (Price, @escaping DemandProviderResponse) -> ()
    
    override init(_ wrapped: W) throws {
        guard let _wrapped = wrapped as? (any ProgrammaticDemandProvider) else { throw SdkError.internalInconsistency }
        
        _bid = { _wrapped.bid($0, response: $1) }
        
        try super.init(wrapped)
    }
    
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        _bid(pricefloor, response)
    }
}


typealias AnyAdViewDemandProvider = AnyDemandProvider<any AdViewDemandProvider>
typealias AnyInterstitialDemandProvider = AnyDemandProvider<any InterstitialDemandProvider>
typealias AnyRewardedAdDemandProvider = AnyDemandProvider<any RewardedAdDemandProvider>

