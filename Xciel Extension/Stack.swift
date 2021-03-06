//
//  Stack.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit

public struct Stack<T>: CustomStringConvertible {
    
    private var list: [T] = []
    
    public var description: String {
        return self.list.map { "\($0)\n" }.reduce("", +)
    }
    
    init() { }
    
    init(_ initialStack: [T]) {
        self.list = initialStack
    }
    
    mutating func push(_ elem: T) {
        self.list.append(elem)
    }
    
    mutating func pop() -> T? {
        if self.isEmpty { return nil }
        let elem = self.list.remove(at: list.count-1)
        return elem
    }
    
    func peek() -> T? {
        if self.isEmpty { return nil }
        return self.list[list.count - 1]
    }
    
    var isEmpty: Bool {
        return self.list.isEmpty
    }
    
    var count: Int {
        return self.list.count
    }
}

public struct BufferStackCell: CustomStringConvertible {
    
    internal let character: Character
    internal let position: XCSourceTextPosition
    
    public var description: String {
        return #"\#(self.position): "\#(self.character)""#
    }
    
    init(character: Character, position: XCSourceTextPosition) {
        self.character = character
        self.position = position
    }
}
