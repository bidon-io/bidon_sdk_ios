//
//  AppTrackingTransparencyPermission.swift
//  Sandbox
//
//  Created by Stas Kochkin on 01.09.2022.
//

import Foundation
import AppTrackingTransparency


struct AppTrackingTransparencyPermission: Permission {
    func request() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            DispatchQueue.main.async {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    DispatchQueue.main.async {
                        continuation.resume()
                    }
                }
            }
        }
    }
}
