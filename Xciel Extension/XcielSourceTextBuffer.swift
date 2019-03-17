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
//
//public struct Bracket: RawRepresentable {
//
//    public init?(rawValue: String) {
//        self.rawValue = ""
//    }
//
//    public var rawValue: String
//
//
//    public typealias RawValue = String
//
//
//    let start: String
//    let end: String
//
//    init(start: String, end: String) {
//        self.start = start
//        self.end = end
//    }
//}
//
//public enum BracketType: Bracket {
//    case Hoge = Bracket(start: "{", end: "}")
//}

public enum BracketType: String {
    case parenthesis   = "\\(\\)"
    case brace         = "\\{\\}"
    case squareBracket = "\\[\\]"
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
    
    public func searchBackward(char: Character) -> XCSourceTextPosition? {
        var pos = self.position
        
        while (pos != beginningOfFile) {
            pos = pos.previousPosition(in: self)
            
            if self.character(at: pos) == char {
                return pos
            }
        }
        
        return nil
    }
    
    public func searchForward(char: Character) -> XCSourceTextPosition? {
        var pos = self.position
        
        while (pos != endOfFile) {
            pos = pos.nextPosition(in: self)
            
            if self.character(at: pos) == char {
                return pos
            }
        }
        
        return nil
    }
    
    // MARK: - CielSearch
    
    public func searchBeginningOfParent(pattern: String = "[{}]") -> XCSourceTextPosition? {
        
        guard let regexp = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        var stack = Stack<BufferStackCell>()
        
        // To make the algorithm easy, I firstly put meaningless bracket.
        
        stack.push(.init(character: "}", position: self.position))
        var pos = self.position
        
        repeat {
            
            guard let matched = regexpSearchBackward(regexp: regexp, position: pos) else {
                return nil
            }
            
            pos = matched
            
            if let peek = stack.peek(), peek.character != String(character(at: pos)) {
                let _ = stack.pop()
            } else {
                let cell = BufferStackCell(character: String(character(at: pos)), position: pos)
                stack.push(cell)
            }
            
        } while (!(stack.isEmpty))
        
        return pos
    }
    
    public func searchEndOfParent(pattern: String = "[\\{\\}]") -> XCSourceTextPosition? {
        
        guard let regexp = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        var stack = Stack<BufferStackCell>()
        
        // To make the algorithm easy, I firstly put meaningless bracket.
        
        stack.push(.init(character: "{", position: self.position))
        var pos = self.position
        
        repeat {
            
            guard let matched = regexpSearchForward(regexp: regexp, position: pos) else {
                return nil
            }
            
            pos = matched
            
            if let peek = stack.peek(), peek.character != String(character(at: pos)) {
                let _ = stack.pop()
            } else {
                let cell = BufferStackCell(character: String(character(at: pos)), position: pos)
                stack.push(cell)
            }
            
            pos = pos.nextPosition(in: self)
            
        } while (!(stack.isEmpty))
        
        return pos
    }
    
    public func searchRegion(options: [CielOption]) -> XCSourceTextRange? {
        
        let beg = self.searchBeginningOfParent()
        let end = self.searchEndOfParent()
        
        if let beg = beg, let end = end {
            
            if options.contains(.exceptStartEndBrackets) {
                return .init(
                    start: beg.nextPosition(in: self),
                    end: end.previousPosition(in: self)
                )
            } else {
                return .init(
                    start: beg,
                    end: end
                )
            }
        }
        
        return nil
    }
    
    // MARK: CielerSearcher
    
    public func cielerSearcher() ->  XCSourceTextRange? {
        
        guard let end = cielerSearchEndOfParent() else {
            return nil
        }
        
        print("えらばれたのは", character(at: end), end, "でした")
        
        let endBracket = character(at: end)
        let pattern: String
        
        switch endBracket {
        case "}":
            pattern = "[\\{\\}]"
        case ")":
            pattern = "[\\(\\)]"
        case "]":
            pattern = "[\\[\\]]"
        default:
            pattern = ""
        }
        
        guard let beg = searchBeginningOfParent(pattern: pattern) else {
            return nil
        }
        
        print(beg, end, character(at: beg), character(at: end))
        
        return XCSourceTextRange(start: beg, end: end)
    }
    
    public func cielerSearchEndOfParent() -> XCSourceTextPosition? {
        
        let pattern: String =
            "["
                + BracketType.parenthesis.rawValue
                + BracketType.brace.rawValue
                + BracketType.squareBracket.rawValue
                + "]"
        
        guard let regexp = try? NSRegularExpression(pattern: pattern) else {
            print("regexp construction failed.")
            return nil
        }
        
        guard !match(regexp: regexp, char: character(at: self.position)) else {
            print("guard first match!")
            return self.position
        }
        
        var stacks: [ BracketType : Stack<BufferStackCell> ] = [
            .parenthesis: Stack<BufferStackCell>(),
            .brace: Stack<BufferStackCell>(),
            .squareBracket: Stack<BufferStackCell>()
        ]
        
        stacks[.parenthesis]?.push(BufferStackCell(character: "(", position: self.position))
        stacks[.brace]?.push(BufferStackCell(character: "{", position: self.position))
        stacks[.squareBracket]?.push(BufferStackCell(character: "[", position: self.position))
        
        var pos = self.position
        
        while (
            !(
                stacks[.parenthesis]?.count == 0 && stacks[.brace]?.count == 1 && stacks[.squareBracket]?.count == 1
                    || stacks[.parenthesis]?.count == 1 && stacks[.brace]?.count == 0 && stacks[.squareBracket]?.count == 1
                    || stacks[.parenthesis]?.count == 1 && stacks[.brace]?.count == 1 && stacks[.squareBracket]?.count == 0
            )
            ) {
                
                pos = pos.nextPosition(in: self)
                
                guard let matched = self.regexpSearchForward(regexp: regexp, position: pos) else {
                    print("match nothing.")
                    return nil
                }
                
                pos = matched
                
                print("matched", character(at: pos), pos)
                
                switch character(at: pos) {
                    
                case Character("("), Character(")"):
                    
                    if let peek = stacks[.parenthesis]?.peek(),
                        peek.character != String(character(at: pos)) {
                        let _ = stacks[.parenthesis]?.pop()
                    } else {
                        let cell = BufferStackCell(character: String(character(at: pos)), position: pos)
                        stacks[.parenthesis]?.push(cell)
                    }
                    
                case Character("{"), Character("}"):
                    
                    if let peek = stacks[.brace]?.peek(),
                        peek.character != String(character(at: pos)) {
                        let _ = stacks[.brace]?.pop()
                    } else {
                        let cell = BufferStackCell(character: String(character(at: pos)), position: pos)
                        stacks[.brace]?.push(cell)
                    }
                    
                case Character("["), Character("]"):
                    
                    if let peek = stacks[.squareBracket]?.peek(),
                        peek.character != String(character(at: pos)) {
                        let _ = stacks[.squareBracket]?.pop()
                    } else {
                        let cell = BufferStackCell(character: String(character(at: pos)), position: pos)
                        stacks[.squareBracket]?.push(cell)
                    }
                    
                default:
                    print("switch default")
                    return nil
                }
                
                // print(stacks[.parenthesis]?.count, stacks[.brace]?.count, stacks[.squareBracket]?.count)
                
        }
        
        return pos
    }
    
    // MARK: Regex Search
    
    public func regexpSearchForward(regexp: NSRegularExpression, position: XCSourceTextPosition) -> XCSourceTextPosition? {
        
        var pos = position
        
        guard !match(regexp: regexp, char: character(at: position)) else {
            print("early return", position, character(at: position))
            return pos
        }
        
        while !(pos == endOfFile) {
            
            pos = pos.nextPosition(in: self)
            let char = character(at: pos)
            
            if match(regexp: regexp, char: char) {
                print("return", pos, character(at: pos))
                return pos
            }
        }
        
        return nil
    }
    
    public func regexpSearchBackward(regexp: NSRegularExpression, position: XCSourceTextPosition) -> XCSourceTextPosition? {
        
        // SearchBackward doesn't look current character, so that search functions can't infinite loop.
        // In other words, SearchBackward starts searching from the previous character.
        
        var pos = position
        
        while !(pos == beginningOfFile) {
            
            pos = pos.previousPosition(in: self)
            let char = character(at: pos)
            
            if match(regexp: regexp, char: char) {
                return pos
            }
        }
        
        return nil
    }
    
    private func match(regexp: NSRegularExpression, char: Character) -> Bool {
        return regexp.matches(in: String(char), range: NSRange(location: 0, length: 1))
            .count > 0
    }
    
    // MARK: Double Quotes
    
    private func countDoubleQuotes(in line: Int) -> Int {
        return self.line(at: line).filter({ $0 == "\"" }).count
    }
    
    private func isQuoted(position: XCSourceTextPosition) -> Bool {
        // TODO
        return false
    }
}
