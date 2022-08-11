//
//  BaseRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


class BaseRequestBuilder {
    private(set) var adaptersRepository: AdaptersRepository!

    private var ext: [String: Any]?
    private var environmentRepository: EnvironmentRepository!
    
    var device: DeviceModel? {
        environmentRepository[.device].map {
            DeviceModel($0)
        }
    }
    
    var session: SessionModel? {
        environmentRepository[.session].map {
            SessionModel($0) }
    }
    
    var app: AppModel? {
        environmentRepository[.app].map {
            AppModel($0) }
    }
    
    var geo: GeoModel? {
        environmentRepository[.geo].map {
            GeoModel($0) }
    }
    
    var user: UserModel? {
        environmentRepository[.user].map {
            UserModel($0) }
    }
    
    var encodedExt: String? {
        ext
        .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
        .flatMap { String(data: $0, encoding: .utf8) }
    }
    
    @discardableResult
    func withAdaptersRepository(_ adaptersRepository: AdaptersRepository) -> Self {
        self.adaptersRepository = adaptersRepository
        return self
    }
   
    @discardableResult
    func withEnvironmentRepository(_ environmentRepository: EnvironmentRepository?) -> Self {
        self.environmentRepository = environmentRepository
        return self
    }
    
    @discardableResult
    func withExt(_ ext: [String: Any]?) -> Self {
        self.ext = ext
        return self
    }
}
