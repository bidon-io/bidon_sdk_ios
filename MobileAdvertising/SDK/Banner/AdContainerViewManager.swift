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
    
    var isAdPresented: Bool {
        guard let container = container else { return false }
        return !container.subviews.isEmpty
    }
    
    func layout(view: UIView) {
        guard
            let container = container,
            !container.subviews.contains(view)
        else { return }
        
        container.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        let constraints: [NSLayoutConstraint] = [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
