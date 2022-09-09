//
//  String.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.09.2022.
//

import Foundation


extension String {
    func camelCaseToSnakeCase() -> String {
        let patterns = [
            "([A-Z]+)([A-Z][a-z]|[0-9])",
            "([a-z0-9])([A-Z])",
            "([a-z])([0-9])"
        ]
        
        return patterns.reduce(self) { result, pattern in
            return result.processCamalCaseRegex(pattern: pattern)
        }
    }
    
    private func processCamalCaseRegex(pattern: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self.lowercased() }
        let range = NSRange(location: 0, length: count)
        
        return regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        )
    }
}
