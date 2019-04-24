//
//  XcielSourceTextBuffer.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit

public enum CielOption {
    case exceptStartEndBrackets
}

open class XcielSourceTextBuffer {
    
    // An extended XCSourceTextBuffer.
    // This class aims to manage easily the buffer which originally is presented as NSMutableArray.
    // Also this provide the strings as String that got from the buffer.
    
    // MARK: - Props
    
    // Usually, storing buffer with [[String]] is a bad practice......
    
    public var lines: [String]
    public var position: XCSourceTextPosition
    public var selection: XCSourceTextRange? = nil
    
    public var completeBuffer: String {
        return self.lines.reduce("", +)
    }
    
    private let originalBuffer: XCSourceTextBuffer
    
    // MARK: - Computed Props
    
    public var lastLine: String {
        return self.lines[self.lines.count - 1]
    }
    
    public var beginningOfFile: XCSourceTextPosition {
        return .init(
            line:   0,
            column: 0
        )
    }
    
    public var endOfFile: XCSourceTextPosition {
        return .init(
            line:   self.lines.count - 1,
            column: self.lastLine.count - 1
        )
    }
    
    // I couldn't override init XCSourceTextBuffer.
    // Get as arguments and store it.
    
    init(original buffer: XCSourceTextBuffer, position: XCSourceTextPosition) {
        self.lines = buffer.lines.compactMap { $0 as? String }
        self.position = position
        self.originalBuffer = buffer
    }
    
    // MARK: - Character
    
    public func characterAt(line: Int, column: Int) -> Character {
        let lineString = self.lines[line]
        let index = lineString.index(lineString.startIndex, offsetBy: column)
        return lineString[index]
    }
    
    public func character(at position: XCSourceTextPosition) -> Character {
        return self.characterAt(line: position.line, column: position.column)
    }
    
    public func currentCharacter() -> Character {
        return character(at: self.position)
    }
    
    // MARK: - Line
    
    public func line(at index: Int) -> String {
        return self.lines[index]
    }
    
    public func lines(from: Int, to: Int) -> [String] {
        return Array(self.lines[from...to])
    }
    
    public func currentLine() -> String {
        return self.lines[position.line]
    }
    
    public func indentation(at line: Int) -> String? {
        let lineString = self.line(at: line)
        
        return lineString.prefix(while: {
            $0 == Character(
                self.originalBuffer.usesTabsForIndentation
                    ? "\t"
                    : " "
            )
        }).map { String($0) }.reduce("", +)
    }
    
    // MARK:- Line String
    
    func string(before position: XCSourceTextPosition) -> String {
        let lineString = self.line(at: position.line)
        let index = lineString.index(lineString.startIndex, offsetBy: position.column)
        return String(lineString[lineString.startIndex..<index])
    }
    
    func string(after position: XCSourceTextPosition) -> String {
        let lineString = self.line(at: position.line)
        let index = lineString.index(lineString.endIndex, offsetBy: (position.column - lineString.count))
        return String(lineString[index..<lineString.endIndex])
    }
    
    func stringInside(of from: XCSourceTextPosition, and to: XCSourceTextPosition) -> String? {
        
        guard from.line == to.line else { return nil }
        
        let lineString = self.line(at: from.line)
        
        let startIndex = lineString.index(lineString.startIndex, offsetBy: from.column)
        let endIndex = lineString.index(lineString.endIndex, offsetBy: to.column - lineString.count)
        
        return String(lineString[startIndex..<endIndex])
    }
    
    func stringOutside(of from: XCSourceTextPosition, and to: XCSourceTextPosition) -> String? {
        guard from.line == to.line else { return nil }
        
        let stringBefore = self.string(before: from)
        let stringAfter = self.string(after: to)
        
        return stringBefore + stringAfter
    }
    
    // MARK: - Search
    
    public func searchBackward(characters: String, position: XCSourceTextPosition) -> XCSourceTextPosition? {
        
        var pos = position
        
        while (pos != beginningOfFile) {
            
            pos = pos.previousPosition(in: self)
            
            if characters.contains(character(at: pos)) {
                return pos
            }
        }
        
        return nil
    }
    
    public func searchForward(characters: String, position: XCSourceTextPosition) -> XCSourceTextPosition? {
        
        var pos = position
        
        guard !characters.contains(character(at: pos)) else {
            return pos
        }
        
        while !(pos == endOfFile) {
            
            pos = pos.nextPosition(in: self)
            
            if characters.contains(character(at: pos)) {
                return pos
            }
        }
        
        return nil
    }
    
    // MARK: - CielSearch
    
    public func searchBeginningOfParent(bracket: BracketType) -> XCSourceTextPosition? {
        
        var stack = Stack<BufferStackCell>([BufferStackCell(
            character: bracket.close,
            position: self.position
            )])
        
        let searchCharacters = String(bracket.open) + String(bracket.close)
        
        var pos = self.position
        
        repeat {
            guard let matched = searchBackward(characters: searchCharacters, position: pos) else {
                return nil
            }
            
            pos = matched
            
            if let peek = stack.peek(), peek.character != character(at: pos) {
                let _ = stack.pop()
            } else {
                let cell = BufferStackCell(character: character(at: pos), position: pos)
                stack.push(cell)
            }
            
        } while (!(stack.isEmpty))
        
        return pos
    }
    
    // MARK: CielerSearcher
    
    public func cielerSearcher() ->  XCSourceTextRange? {
        
        guard let end = cielerSearchEndOfParent() else {
            print("❌ cielerSearchEndOfParent failed.")
            return nil
        }
        
        guard let bracket = BracketType(rawValue: character(at: end)),
              let beg = searchBeginningOfParent(bracket: bracket) else {
            print("❌ searchBeginningOfParent failed. end: \(end), char: \(character(at: end)).")
            self.debugPrint(end)
            return nil
        }
        
        print("🎉 A pair found! beg: \(beg), end:\(end).")
        self.debugPrint(beg, end)
        
        return XCSourceTextRange(start: beg, end: end)
    }
    
    public func cielerSearchEndOfParent() -> XCSourceTextPosition? {
    
        guard BracketType.allCases.allSatisfy({ $0.close != self.character(at: position) }) else {
                return self.position
        }
        
        var stacks: [BracketType : Stack<BufferStackCell>] = [:]
        
        BracketType.allCases.forEach { bracket in
            stacks[bracket] = Stack<BufferStackCell>([
                BufferStackCell(
                    character: bracket.open,
                    position: self.position
                )])
        }
        
        let isFinished = {
            stacks.filter { $1.count == 0 }.count == 1
        }
        
        let searchCharacters = BracketType.allCases.reduce(into: "") { (res, bracket) in
            res += String(bracket.open) + String(bracket.close)
        }
        
        var pos = self.position
        
        while !isFinished() {
            
            pos = pos.nextPosition(in: self)
        
            guard let matched = self.searchForward(characters: searchCharacters, position: pos) else {
                return nil
            }
            
            let char = character(at: matched)
            
            guard let bracketType = BracketType(rawValue: char) else {
                return nil
            }
            
            pos = matched
            
            if let peek = stacks[bracketType]?.peek(), peek.character != char {
                let _ = stacks[bracketType]?.pop()
            } else {
                let cell = BufferStackCell(character: char, position: pos)
                stacks[bracketType]?.push(cell)
            }
        }
        
        return pos
    }
    
    // MARK: Comment
    
    public func isCommented(range: XCSourceTextRange) -> Bool {
        return lines(from: range.start.line, to: range.end.line)
            .allSatisfy { $0.isCommented() }
    }
    
    // MARK: Debug
    
    public func debugPrint(_ positions: XCSourceTextPosition...) {
        
        for pos in positions {
            
            let positionMarkedString =
                (string(before: pos) + "🔲" + string(after: pos))
                    .map { (char: Character) -> String in
                        switch char {
                        case "\n":
                            return ""
                        default:
                            return String(char)
                        }
                    }
                    .reduce("", +)
            
            print("""
                🚩 \(pos):
                \(positionMarkedString)
                """)
        }
    }
}
