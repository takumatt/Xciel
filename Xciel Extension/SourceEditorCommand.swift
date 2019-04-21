//
//  SourceEditorCommand.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit


class XcielDeleteRegionCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            // kill region
            
            invocation.buffer.killNicely(range: range, exceptStartEndLine: true, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

class XcielDeleteRegionIncludesCursorLineCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            invocation.buffer.killNicely(range: range, exceptStartEndLine: false, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

class XcielCommentOutRegionCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            // comment out
            
            invocation.buffer.toggleComment(range: range, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

class XcielCommentOutRegionIncludesCursorLineCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }

        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)

        if let range = cielBuffer.cielerSearcher() {

            // comment out

            invocation.buffer.toggleComment(range: range, in: cielBuffer, exceptStartEndLine: false)
        }

        completionHandler(nil)
    }
}

class XcielSelectRegionCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            // select region
            
            invocation.buffer.select(range: range, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

//class XcielSelectRegionIncludesLineCommand: NSObject, XCSourceEditorCommand {
//
//    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
//
//        guard let pos = invocation.buffer.currentPosition() else {
//            return completionHandler(nil)
//        }
//
//        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
//
//        if let range = cielBuffer.cielerSearcher() {
//
//            // select region
//
//            invocation.buffer.select(range: range, in: cielBuffer, exceptStartEndLine: false)
//        }
//
//        completionHandler(nil)
//    }
//}
