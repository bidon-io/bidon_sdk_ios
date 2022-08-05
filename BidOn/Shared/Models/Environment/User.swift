//
//  User.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


#warning("Fill in all required fields")
protocol User: Environment {
    var idfa: String { get }
}


struct CodableUser: User, Codable {
    var idfa: String
    
    init(_ user: User) {
        self.idfa = user.idfa
    }
}
