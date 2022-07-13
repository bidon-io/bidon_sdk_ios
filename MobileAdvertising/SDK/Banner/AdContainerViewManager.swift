//
//  AdContainerViewManager.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit


final internal class AdContainerViewManager {
    weak var container: UIView?
    
    private var timer: Timer?
    
    var isAdPresented: Bool {
        guard let container = container else { return false }
        return !container.subviews.isEmpty
    }
    
    var isRefreshGranted: Bool { timer == nil && isAdPresented }
    
    func schedule(
        _ interval: TimeInterval,
        block: (() -> ())?
    ) {
        let timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.timer = nil
            block?()
        }
        
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
    
    func cancelRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func layout(view: AdView, size: CGSize) {
        guard
            let container = container,
            !container.subviews.contains(view)
        else { return }
        
        container.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        let constraints: [NSLayoutConstraint]
        
        if view.isAdaptive {
            constraints = [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        } else {
            constraints = [
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.widthAnchor.constraint(equalToConstant: size.width),
                view.heightAnchor.constraint(equalToConstant: size.height)
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}
