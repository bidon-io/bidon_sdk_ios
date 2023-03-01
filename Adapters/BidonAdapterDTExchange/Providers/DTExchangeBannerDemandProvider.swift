//
//  DTExchangeBannerDemandProvider.swift
//  BidonAdapterDTExchange
//
//  Created by Bidon Team on 28.02.2023.
//

import Foundation
import Bidon
import IASDKCore
import UIKit


final class DTExchangeBannerDemandProvider: DTExchangeBaseDemandProvider<IAViewUnitController> {
    private var presentedAdWrapper: DTExchangeAdWrapper?
    private weak var rootViewController: UIViewController?
    
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    private lazy var mraidController = IAMRAIDContentController.build { builder in
        builder.mraidContentDelegate = self
    }
    
    private lazy var controller: IAViewUnitController = {
        let controller = IAViewUnitController.build { [unowned self] builder in
            self.mraidController.map(builder.addSupportedContentController)
            builder.unitDelegate = self
        }
        
        guard let controller = controller else { fatalError("Unable to create IAViewUnitController controller") }
        return controller
    }()
    
    override func unitController() -> IAViewUnitController {
        return controller
    }
}


extension DTExchangeBannerDemandProvider: AdViewDemandProvider {
    func container(for ad: Ad) -> AdViewContainer? {
        guard
            let ad = ad as? DTExchangeAdWrapper,
            ad.adSpot.activeUnitController === controller,
            controller.isReady()
        else { return nil }
        
        self.presentedAdWrapper = ad
        
        return controller.adView
    }
}


extension DTExchangeBannerDemandProvider: IAMRAIDContentDelegate {}


extension DTExchangeBannerDemandProvider: IAUnitDelegate {
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return rootViewController ?? UIApplication.shared.bd.topViewcontroller ?? UIViewController()
    }
    
    func iaUnitControllerWillPresentFullscreen(_ unitController: IAUnitController?) {
        delegate?.providerWillPresent(self)
    }
    
    func iaAdWillLogImpression(_ unitController: IAUnitController?) {
        guard let ad = presentedAdWrapper else { return }
        let revenue = AdRevenueWrapper(eCPM: ad.eCPM, wrapped: ad)
        revenueDelegate?.provider(self, didPay: revenue, ad: ad)
    }
    
    func iaAdDidReceiveClick(_ unitController: IAUnitController?) {
        delegate?.providerDidClick(self)
    }
    
    func iaUnitControllerDidDismissFullscreen(_ unitController: IAUnitController?) {
        delegate?.providerDidHide(self)
    }
}


extension IAAdView: AdViewContainer {
    public var isAdaptive: Bool { return false }
}
