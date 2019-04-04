//
//  String+Comment.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/04/01.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation

extension String {
    
    func commentPrefixRange() -> Range<String.Index>? {
        
        let pattern = #"//"#
        
        return self.range(of: pattern, options: .regularExpression)
    }
    
    func isCommented() -> Bool {
        
        let pattern = #"^\s*//.*$"#
        
        return self.range(of: pattern, options: .regularExpression) != nil
    }
    
    func uncommented() -> String {
        
        guard let range = self.commentPrefixRange() else {
            return self
        }
        
        return String(self[range.upperBound...])
    }
    
    func commented() -> String {
        
        return "//\(self)"
    }
}
