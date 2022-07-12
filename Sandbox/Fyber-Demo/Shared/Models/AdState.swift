//
//  AdState.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI


enum AdState {
    case idle
    case loading
    case ready
    case presenting
    case failed
}


extension AdState {
    var text: String {
        switch self {
        case .idle, .failed: return "Load"
        case .loading: return "Loading"
        default: return "Present"
        }
    }
    
    var color: Color {
        switch self {
        case .idle: return .blue
        case .ready: return .green
        case .failed: return .red
        default: return .gray
        }
    }
    
    var disabled: Bool {
        switch self {
        case .loading, .presenting: return true
        default: return false
        }
    }
    
    var isAnimating: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    var isFailed: Bool {
        switch self {
        case .failed: return true
        default: return false
        }
    }
    
    var isReady: Bool {
        switch self {
        case .ready: return true
        default: return false
        }
    }
}
