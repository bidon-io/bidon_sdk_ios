//
//  GCD.swift
//  BidOn
//
//  Created by Stas Kochkin on 10.08.2022.
//

import Foundation



extension DispatchQueue {
    static var bd: DSL { DSL() }
    
    struct DSL {
        @discardableResult
        func perform<T>(_ block: @escaping () throws -> T) throws -> T {
            if Thread.current.isMainThread {
                return try block()
            } else {
                let semaphore = DispatchSemaphore(value: 0)
                
                var _result: T?
                var _error: Error?
                
                DispatchQueue.main.async {
                    do {
                    _result = try block()
                    } catch {
                        _error = error
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                
                guard let result = _result
                else { throw _error ?? SdkError.unknown }
                
                return result
            }
        }
    }
}

