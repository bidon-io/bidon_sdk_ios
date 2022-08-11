//
//  SessionModel.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


struct SessionModel: Session, Codable {
    var id: String
    
    init(_ session: Session) {
        self.id = session.id
    }
}
