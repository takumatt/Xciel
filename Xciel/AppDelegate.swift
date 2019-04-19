//
//  AppDelegate.swift
//  Xciel
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
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
        
        do {
            self.window.title = "Xciel"
            self.window.titlebarAppearsTransparent = false
            self.window.titleVisibility = .visible
            self.window.contentViewController = viewController
        }
        
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
    
    private let logoImageView: NSImageView = {
        let imageView = NSImageView()
        // imageView.
        return imageView
    }()
    
    private let titleText: NSText = {
        let text = NSText()
        return text
    }()
    
    private let versionInfoText: NSText = {
        let text = NSText()
        return text
    }()
    
    private let suggestionText: NSText = {
        let text = NSText()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.string = """
        Please ensure System Preferences > Extensions > Xciel is enabled.
        """
        text.backgroundColor = .clear
        text.alignment = .center
        text.isEditable = false
        return text
    }()
    
    private let openPreferencesButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = "Open Extensions in System Preferences"
        button.action = #selector(tap)
        return button
    }()
    
    override func loadView() {
        self.view = NSView(frame: .init(x: 0, y: 0, width: 640, height: 400))
    }
    
    override func viewDidLoad() {
        
        self.view.addSubview(suggestionText)
        self.view.addSubview(openPreferencesButton)
        
        NSLayoutConstraint.activate([
            suggestionText.bottomAnchor.constraint(equalTo: self.openPreferencesButton.topAnchor),
            suggestionText.heightAnchor.constraint(equalToConstant: 32.0),
            suggestionText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            suggestionText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        
        NSLayoutConstraint.activate([
            openPreferencesButton.topAnchor.constraint(equalTo: self.suggestionText.bottomAnchor),
            openPreferencesButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            openPreferencesButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -24.0)
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
