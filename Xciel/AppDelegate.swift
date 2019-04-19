//
//  AppDelegate.swift
//  Xciel
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Cocoa

// @NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // @IBOutlet weak var window: NSWindow!
    
//    private let window: NSWindow = {
//        let viewController = ViewController()
//        let window = NSWindow(contentViewController: viewController)
//        window.title = "Xciel"
//        return window
//    }()
    
    private var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let viewController = ViewController()
        
        self.window = NSWindow(
            contentRect: .zero,
            styleMask: [
                .closable,
                .titled,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        
        self.window.title = "Xciel"
        self.window.titlebarAppearsTransparent = false
        self.window.titleVisibility = .visible
        self.window.contentViewController = viewController
        
        self.window.center()
        self.window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

final class ViewController: NSViewController {
    
    private let button: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.stringValue = "HOge"
        button.action = #selector(tap)
        return button
    }()
    
    override func loadView() {
        self.view = NSView(frame: .init(x: 0, y: 0, width: 300, height: 300))
    }
    
    override func viewDidLoad() {
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.view.topAnchor),
            button.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            button.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
    }
    
    @objc
    func tap() {
        
        let url = URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane")
        
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
}
