//
//  UserModel.swift
//  Bidon
//
//  Created by Bidon Team on 09.08.2022.
//

import Foundation


typealias UserModel = AbstractUserModel<UserManager.Consent>

struct AbstractUserModel<Consent: Codable>: User, Codable {
    var trackingAuthorizationStatus: TrackingAuthorizationStatus
    var idfv: String
    var idg: String
    var coppa: Bool
    var consent: Consent
    var idfa: String
    
    init<UserType: User>(_ user: UserType) where Consent == UserType.Consent {
        self.idfa = user.idfa
        self.idfv = user.idfv
        self.idg = user.idg
        self.coppa = user.coppa
        self.consent = user.consent
        self.trackingAuthorizationStatus = user.trackingAuthorizationStatus
    }
}
