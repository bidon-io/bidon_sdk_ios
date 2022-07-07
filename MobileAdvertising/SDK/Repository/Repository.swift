//
//  Repository.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation


public final class Repository<Key, Value> where Key: Hashable {
    internal let queue: DispatchQueue
    internal var objects: [Key: Any]
    
    public init(_ queueName: String) {
        objects = [:]
        queue = DispatchQueue(
            label: queueName,
            attributes: .concurrent
        )
    }

    var isEmpty: Bool {
        return objects.isEmpty
    }
    
    private func value<T>(_ key: Key) -> T? {
        queue.sync { [unowned self] in
            return self.objects[key] as? T
        }
    }
    
    private func setValue<T>(_ value: T, key: Key) {
        queue.async(flags: .barrier) { [weak self] in
            self?.objects[key] = value
        }
    }
    
    public subscript<T>(key: Key) -> T? {
        get { value(key) }
        set { setValue(newValue, key: key) }
    }
    
    
    func all<T>() -> [T] {
        queue.sync { [unowned self] in
            return self.objects.values.compactMap { $0 as? T }
        }
    }
}
