//
//  XCSourceTextBuffer+Util.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit

enum KillLineOption {
    case exceptStartEndLine
}

extension XCSourceTextBuffer  {
    
    // MARK: - Select
    
    func select(range: XCSourceTextRange) {
        let selection: XCSourceTextRange = .init(
            start: XCSourceTextPosition(
                line: range.start.line,
                column: range.start.column + 1
            ),
            end: range.end
        )
        
        self.selections.replaceObject(at: 0, with: selection)
    }
    
    // MARK: - Comment
    
    func commentOut(range: XCSourceTextRange, in buffer: XcielSourceTextBuffer, exceptStartEndLine: Bool = true) {
        
         guard range.start.line != range.end.line else {

            self.lines.replaceObject(
                at: range.start.line,
                with: "// " + buffer.line(at: range.start.line)
            )
            
            return
        }
        
        let startLine: Int
        let endLine: Int
        
        if exceptStartEndLine {
            startLine = range.start.line + 1
            endLine = range.end.line - 1
        } else {
            startLine = range.start.line
            endLine = range.end.line
        }
        
        let newLines = buffer.lines(from: startLine, to: endLine)
        let commentedLines = newLines.map { "// " + $0 }

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
    
    func kill(range: XCSourceTextRange, startOffset: Int = 0, endOffset: Int = 0) {
        
        // Delete lines including start and end line.
        
        let startLine = range.start.line + startOffset
        let endLine = range.end.line + endOffset
        
        self.lines.removeObjects(in: NSRange(
            location: startLine,
            length: endLine - startLine + 1
            )
        )
    }
    
    // MARK: - Ciel
    
    func killNicely(range: XCSourceTextRange, exceptStartEndLine: Bool = false, in buffer: XcielSourceTextBuffer) {
        
        if range.start.line == range.end.line {
            
            self.killInLine(
                between: range.start.nextPosition(in: buffer),
                and: range.end,
                in: buffer
            )
            
            self.move(position: .init(
                line: range.start.line,
                column: range.start.column + 1
                )
            )
            
            return
        }
        
        if !exceptStartEndLine {
            self.kill(
                range: range
            )
        }
        
        let indentation = buffer.indentation(at: range.start.line + 1)
        
        self.replace(
            line: range.start.line + 1,
            with: indentation ?? ""
        )
        
        self.kill(
            range: range,
            startOffset: 2,
            endOffset: -1
        )
        
        let cursorPosition = XCSourceTextPosition(
            line: range.start.line + 1,
            column: buffer.line(at: range.start.line).count - 1
        )
        
        self.move(position: cursorPosition)
        
    }
}

