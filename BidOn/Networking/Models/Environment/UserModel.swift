//
//  UserModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


struct UserModel: User, Codable {
    var idfa: String
    
    init(_ user: User) {
        self.idfa = user.idfa
    }
}
