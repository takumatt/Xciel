//
//  String+Comment.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/04/01.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation

extension String {
    
    func isCommented() -> Bool {
        
        let pattern = "^[ \t\n\r]+\\/\\/.*"
        
        guard let regexp = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        
        let matches = regexp.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
        
        // XXX: this codes doesn't work, it also should be used the following code since swift 5.
        // self.range(of: #"=t"#, options: .regularExpression)
        
        print(matches)
        
        if matches.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func commented() -> String {
        return "// " + self
    }
    
    func uncommented() -> String {
        
        guard let index = self.firstIndex(where: { $0 == Character("/") } ) else {
            return self
        }
        
        let uncommentedIndex = self.index(index, offsetBy: 2)
        return String(self[uncommentedIndex..<self.endIndex])
    }
    
}
