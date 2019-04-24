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
        let imageView = NSImageView(image: NSImage(named: "AppIcon")!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let appText: NSTextField = {
        let text = NSTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        let version = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String) ?? ""
        text.stringValue = """
        Xciel \(version)
        """
        text.font = NSFont.boldSystemFont(ofSize: 18.0)
        text.isEditable = false
        text.isBezeled = false
        text.drawsBackground = false
        return text
    }()
    
    private let infoText: NSTextField = {
        let text = NSTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.stringValue = """
        Written by Takuma Matsushita
        
        If you have any issues or suggestions, please report from here.
        We appreciate any suggestion! (e.g. language error)
        """
        text.isEditable = false
        text.isBezeled = false
        text.drawsBackground = false
        return text
    }()

    private let suggestionText: NSTextField = {
        let text = NSTextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.stringValue = """
        Please ensure System Preferences > Extensions > Xciel is enabled.
        """
        text.alignment = .center
        text.isEditable = false
        text.isBezeled = false
        text.drawsBackground = false
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
        self.view = NSView(frame: .init(x: 0, y: 0, width: 480, height: 320))
    }
    
    override func viewDidLoad() {
        
        let containerView: NSView = {
            let view = NSView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.view.addSubview(logoImageView)
        self.view.addSubview(containerView)
        containerView.addSubview(appText)
        containerView.addSubview(infoText)
        self.view.addSubview(suggestionText)
        self.view.addSubview(openPreferencesButton)
        
        logoImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        logoImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64.0),
            logoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40.0)
            ])
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 24.0),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24.0)
            ])
        
        NSLayoutConstraint.activate([
            appText.topAnchor.constraint(equalTo: containerView.topAnchor),
            appText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            appText.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        
        NSLayoutConstraint.activate([
            infoText.topAnchor.constraint(equalTo: appText.bottomAnchor, constant: 12.0),
            infoText.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            infoText.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            infoText.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        
        NSLayoutConstraint.activate([
            suggestionText.bottomAnchor.constraint(equalTo: self.openPreferencesButton.topAnchor, constant: -12.0),
            suggestionText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            suggestionText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        
        NSLayoutConstraint.activate([
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
