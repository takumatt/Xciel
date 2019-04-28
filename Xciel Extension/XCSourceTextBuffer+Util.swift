//
//  XCSourceTextBuffer+Util.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit

public struct CielOptions: OptionSet {
    
    public let rawValue: Int
    
    public static let greedy = CielOptions(rawValue: 1 << 0)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension XCSourceTextBuffer  {
    
    // MARK: - Select
    
    func select(range: XCSourceTextRange, in buffer: XcielSourceTextBuffer, options: [CielOptions] = []) {
        self.selections.replaceObject(at: 0, with: range)
    }
    
    // MARK: - Delete
    
    func delete(range: XCSourceTextRange, in buffer: XcielSourceTextBuffer, options: [CielOptions] = []) {
        
        let target: XCSourceTextRange = options.contains(.greedy)
            ? range
            : .init(start: .init(line: range.start.line + 1, column: range.start.column),
                    end:   .init(line: range.end.line - 1,   column: range.end.column))
        
        self.kill(range: target, in: buffer)
    }
    
    // MARK: - Comment
    
    func comment(range: XCSourceTextRange, in buffer: XcielSourceTextBuffer, options: [CielOptions] = []) {
        
        let target: XCSourceTextRange = options.contains(.greedy)
            ? range
            : .init(start: .init(line: range.start.line + 1, column: range.start.column),
                    end:   .init(line: range.end.line - 1,   column: range.end.column))
        
        toggleComment(range: target, in: buffer)
    }
    
    func toggleComment(range: XCSourceTextRange, in buffer: XcielSourceTextBuffer) {
        
        guard range.start.line != range.end.line else {
            
            if buffer.line(at: range.start.line).isCommented() {

                self.lines.replaceObject(
                    at: range.start.line,
                    with: buffer.line(at: range.start.line).uncommented()
                )
            } else {
                
                self.lines.replaceObject(
                    at: range.start.line,
                    with: buffer.line(at: range.start.line).commented()
                )
            }
            return
        }
        
        let startLine = range.start.line
        let endLine = range.end.line
        
        let commentedLines: [String]
        
        if buffer.isCommented(range: range) {
            commentedLines = buffer
                .lines(from: startLine, to: endLine)
                .map { $0.uncommented() }
        } else {
            commentedLines = buffer
                .lines(from: startLine, to: endLine)
                .map { $0.commented() }
        }
        
        self.lines.replaceObjects(in: NSRange(
            location: startLine,
            length: endLine - startLine + 1
        ), withObjectsFrom: commentedLines)
    }
    
    // MARK: - Cursor
    
    func currentPosition() -> XCSourceTextPosition? {
        
        // return a position where current cursor is.
        
        guard let selection = self.selections.firstObject as? XCSourceTextRange else { return nil }
        return selection.start
    }
    
    func move(position: XCSourceTextPosition) {
        self.selections.replaceObject(
            at: 0,
            with: XCSourceTextRange(
                start: position,
                end: position
            )
        )
    }
    
    // MARK: - Replace
    
    func replace(line: Int, with str: String) {
        self.lines.replaceObject(at: line, with: str)
    }
    
    // MARK: - Kill
    
    func killInLine(before pos: XCSourceTextPosition, in buf: XcielSourceTextBuffer) {
        let newString = buf.string(after: pos)
        self.lines.replaceObject(at: pos.line, with: newString)
    }
    
    func killInLine(after pos: XCSourceTextPosition, in buf: XcielSourceTextBuffer) {
        let newString = buf.string(before: pos)
        self.lines.replaceObject(at: pos.line, with: newString)
    }
    
    func killInLine(between beg: XCSourceTextPosition, and end: XCSourceTextPosition, in buf: XcielSourceTextBuffer, fillWith fillString: String = "") {
        guard beg.line == end.line else { return }
        
        let newString = buf.string(before: beg) + fillString + buf.string(after: end)
        self.lines.replaceObject(at: beg.line, with: newString)
    }
    
    func kill(range: XCSourceTextRange, in buffer: XcielSourceTextBuffer) {
        
        // TODO: Copy to clipboard
        
        guard range.start.line != range.end.line else {
            
            self.killInLine(
                between: range.start.nextPosition(in: buffer),
                and: range.end,
                in: buffer
            )
            
            self.move(
                position: .init(
                    line: range.start.line,
                    column: range.start.column + 1
                )
            )
            
            return
        }
        
        let indentation = buffer.indentation(at: range.start.line)
        
        self.replace(
            line: range.start.line,
            with: indentation ?? ""
        )
        
        self.lines.removeObjects(in: NSRange(
            location: range.start.line,
            length: range.end.line - range.start.line + 1
            )
        )
        
        let cursorPosition = XCSourceTextPosition(
            line: range.start.line,
            column: buffer.line(at: range.start.line).count - 1
        )
        
        self.move(position: cursorPosition)
    }
}

