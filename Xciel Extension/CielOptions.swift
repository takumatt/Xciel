//
//  CielOptions.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/04/29.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation

public struct CielOptions: OptionSet {
    
    public let rawValue: Int
    
    public static let greedy = CielOptions(rawValue: 1 << 0)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
