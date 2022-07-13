//
//  AdBannerView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import SwiftUI
import AppLovinSDK
import AppLovinDecorator
import MobileAdvertising


struct AdBannerView: UIViewRepresentable {
    typealias UIViewType = BNMAAdView
    
    @Binding var isAutoRefresh: Bool
    @Binding var autorefreshInterval: TimeInterval
    @Binding var isAdaptive: Bool

    var adUnitIdentifier: String
    var adFormat: MAAdFormat
    var sdk: ALSdk
    var event: (AdEvent) -> ()
    
    func makeUIView(context: Context) -> BNMAAdView {
        let view = BNMAAdView(
            adUnitIdentifier: adUnitIdentifier,
            adFormat: adFormat,
            sdk: sdk
        )

        view.delegate = context.coordinator
        view.auctionDelegate = context.coordinator
        view.revenueDelegate = context.coordinator
        view.adReviewDelegate = context.coordinator
        view.resolver = resolver
        view.loadAd()
        
        return view
    }
    
    func updateUIView(_ uiView: BNMAAdView, context: Context) {
        isAutoRefresh ? uiView.startAutoRefresh() : uiView.stopAutoRefresh()
        uiView.autorefreshInterval = autorefreshInterval
        uiView.setExtraParameterForKey("adaptive_banner", value: isAdaptive ? "true" : "false")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(event: event)
    }
    
    class Coordinator: NSObject, BNMAAdViewAdDelegate, BNMAuctionDelegate, BNMAAdRevenueDelegate, BNMAAdReviewDelegate {
        let event: (AdEvent) -> ()
        
        init(event: @escaping (AdEvent) -> ()) {
            self.event = event
            super.init()
        }
        
        func didExpand(_ ad: Ad) {
            event(.didExpand(ad: ad))
        }
        
        func didCollapse(_ ad: Ad) {
            event(.didCollapse(ad: ad))
        }
        
        func didLoad(_ ad: Ad) {
            event(.didLoad(ad: ad))
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: Error) {
            event(.didFail(id: adUnitIdentifier, error: error))
        }
        
        func didDisplay(_ ad: Ad) {
            event(.didDisplay(ad: ad))
        }
        
        func didHide(_ ad: Ad) {
            event(.didHide(ad: ad))
        }
        
        func didClick(_ ad: Ad) {
            event(.didClick(ad: ad))
        }
        
        func didFail(toDisplay ad: Ad, withError error: Error) {
            event(.didDisplayFail(ad: ad, error: error))
        }
        
        func didStartAuction() {
            event(.didStartAuction)
        }
        
        func didStartAuctionRound(_ round: String, pricefloor: Price) {
            event(.didStartAuctionRound(id: round, pricefloor: pricefloor))
        }
        
        func didReceiveAd(_ ad: Ad) {
            event(.didReceive(ad: ad))
        }
        
        func didCompleteAuctionRound(_ round: String) {
            event(.didCompleteAuctionRound(id: round))
        }
        
        func didCompleteAuction(_ winner: Ad?) {
            event(.didCompleteAuction(ad: winner))
        }
        
        func didPayRevenue(for ad: Ad) {
            event(.didPay(ad: ad))
        }
        
        func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: Ad) {
            event(.didGenerateCreativeId(id: creativeIdentifier, ad: ad))
        }
    }
}
