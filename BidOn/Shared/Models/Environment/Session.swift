//
//  Session.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation

#warning("Fill in all required fields")
protocol Session: Environment {
    var id: String { get }
}


struct CodableSession: Session, Codable {
    var id: String
    
    init(_ session: Session) {
        self.id = session.id
    }
}


