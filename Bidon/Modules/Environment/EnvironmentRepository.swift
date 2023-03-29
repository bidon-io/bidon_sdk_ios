//
//  EnvironmentRepository.swift
//  Bidon
//
//  Created by Bidon Team on 05.08.2022.
//

import Foundation


internal typealias EnvironmentRepository = Repository<EnvironmentRepositoryKey, EnvironmentManager>


enum EnvironmentRepositoryKey: String {
    case device
    case session
    case app
    case user
    case geo
}


extension EnvironmentRepository {
    struct Parameters {
        var appKey: String
        var framework: Framework
        var frameworkVersion: String?
        var pluginVersion: String?
    }
    
    convenience init() {
        self.init("com.bidon.adapters-repository.queue")
    }
    
    func configure(_ parameters: Parameters, completion: @escaping () -> ()) {
        self[.device] = DeviceManager()
        self[.session] = SessionManager()
        self[.app] = AppManager(
            key: parameters.appKey,
            framework: parameters.framework,
            frameworkVersion: parameters.frameworkVersion,
            pluginVersion: parameters.pluginVersion
        )
        self[.user] = UserManager()
        
        let geo = GeoManager()
        self[.geo] = geo
        
        guard geo.isAvailable else {
            completion()
            return
        }
        
        geo.prepare(completion: completion)
    }

    
    func environment<T: EnvironmentManager>(_ type: T.Type) -> T? {
        guard let key = EnvironmentRepositoryKey(type) else { return nil }
        let env: T? = self[key]
        return env
    }
}


extension EnvironmentRepositoryKey {
    init?<T: EnvironmentManager>(_ type: T.Type) {
        switch type {
        case is DeviceManager.Type: self = .device
        case is SessionManager.Type: self = .session
        case is AppManager.Type: self = .app
        case is UserManager.Type: self = .user
        case is GeoManager.Type: self = .geo
        default: return nil
        }
    }
}



