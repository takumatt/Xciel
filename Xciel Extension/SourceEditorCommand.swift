//
//  SourceEditorCommand.swift
//  Xciel Extension
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Foundation
import XcodeKit

// MARK: Delete

class XcielDeleteRegionCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            invocation.buffer.killNicely(range: range, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

class XcielDeleteRegionGreedilyCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            invocation.buffer.killNicely(range: range, in: cielBuffer, options: [.greedy])
        }
        
        completionHandler(nil)
    }
}

// MARK: Comment

class XcielCommentOutRegionCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            invocation.buffer.toggleComment(range: range, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

class XcielCommentOutRegionGreedilyCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }

        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)

        if let range = cielBuffer.cielerSearcher() {

            invocation.buffer.toggleComment(range: range, in: cielBuffer, options: [.greedy])
        }

        completionHandler(nil)
    }
}

// MARK: Select

class XcielSelectRegionCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }
        
        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)
        
        if let range = cielBuffer.cielerSearcher() {
            
            invocation.buffer.select(range: range, in: cielBuffer)
        }
        
        completionHandler(nil)
    }
}

class XcielSelectRegionGreedilyCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

        guard let pos = invocation.buffer.currentPosition() else {
            return completionHandler(nil)
        }

        let cielBuffer = XcielSourceTextBuffer(original: invocation.buffer, position: pos)

        if let range = cielBuffer.cielerSearcher() {

            // select region

            invocation.buffer.select(range: range, in: cielBuffer, options: [.greedy])
        }

        completionHandler(nil)
    }
}
