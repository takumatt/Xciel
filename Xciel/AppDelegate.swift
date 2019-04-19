//
//  AppDelegate.swift
//  Xciel
//
//  Created by Takuma Matsushita on 2019/03/17.
//  Copyright © 2019 Takuma Matsushita. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        window.contentView = ViewController().view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

final class ViewController: NSViewController {
    
    private let button: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.stringValue = "HOge"
        return button
    }()
    
    override func loadView() {
        self.view = NSView()
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
}

