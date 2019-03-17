//
//  XCSourceTextPosition+Util.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit

extension XCSourceTextPosition: Equatable {
    
    public static func ==(lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        return lhs.line == rhs.line && lhs.column == rhs.column
    }
}

extension XCSourceTextPosition {
    
    func previousPosition(in buffer: XcielSourceTextBuffer) -> XCSourceTextPosition {
        
        guard self != buffer.beginningOfFile else { return self }
        
        if self.column == 0 {
            let prevLine = self.line - 1
            let prevColumn = buffer.line(at: self.line - 1).count - 1
            return .init(line: prevLine, column: prevColumn)
        } else {
            return .init(line: self.line, column: self.column - 1)
        }
    }
    
    func nextPosition(in buffer: XcielSourceTextBuffer) -> XCSourceTextPosition {
        
        guard self != buffer.endOfFile else { return self }
        
        let lastColumn = buffer.line(at: self.line).count - 1
        if self.column >= lastColumn {
            let nextLine = self.line + 1
            let nextColumn = 0
            return .init(line: nextLine, column: nextColumn)
        } else {
            return .init(line: self.line, column: self.column + 1)
        }
    }
}
