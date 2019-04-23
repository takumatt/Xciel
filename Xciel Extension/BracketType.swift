//
//  BracketType.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/04/12.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation

public enum BracketType: RawRepresentable, CaseIterable {

    case paren
    case brace
    case square
    case angle
    
    public typealias Bracket = (open: Character, close: Character)
    
    private static let parenBracket:  Bracket = (open: "(", close: ")")
    private static let braceBracket:  Bracket = (open: "{", close: "}")
    private static let squareBracket: Bracket = (open: "[", close: "]")
    private static let angleBracket:  Bracket = (open: "<", close: ">")
    
    public var rawValue: Bracket {
        switch self {
        case .paren:
            return type(of: self).parenBracket
        case .brace:
            return type(of: self).braceBracket
        case .square:
            return type(of: self).squareBracket
        case .angle:
            return type(of: self).angleBracket
        }
    }
    
    public var open: Character {
        return self.rawValue.0
    }
    
    public var close: Character {
        return self.rawValue.1
    }
    
    public init?(rawValue: Bracket) {
        switch rawValue {
        case ("(", ")"):
            self = .paren
        case ("{", "}"):
            self = .brace
        case ("[", "]"):
            self = .square
        case ("<", ">"):
            self = .angle
        default: return nil
        }
    }
    
    public init?(rawValue: Character) {
        switch rawValue {
        case "(", ")":
            self = .paren
        case "{", "}":
            self = .brace
        case "[", "]":
            self = .square
        case "<", ">":
            self = .angle
        default: return nil
        }
    }
}
