//
//  UIApplication+Extensions.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import UIKit


public extension UIApplication {
    var topViewContoller: UIViewController? {
        if #available(iOS 13.0, *) {
            return connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .map { $0.windows }
                .reduce([], +)
                .first { $0.isKeyWindow }
                .flatMap { $0.topPresentedViewController() }
        } else {
            return keyWindow?.topPresentedViewController()
        }
     }
}


internal extension UIWindow {
    func topPresentedViewController() -> UIViewController? {
        var topViewController = rootViewController
        while (true) {
            if topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController;
            } else if let navigationViewController = topViewController as? UINavigationController  {
                topViewController = navigationViewController.topViewController;
            } else if let tabBarViewController = topViewController as? UITabBarController {
                topViewController = tabBarViewController.selectedViewController;
            } else {
                break;
            }
        }
        return topViewController;
    }
}
