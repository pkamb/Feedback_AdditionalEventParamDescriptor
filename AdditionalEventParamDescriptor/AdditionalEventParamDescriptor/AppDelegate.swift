//
//  AppDelegate.swift
//  AdditionalEventParamDescriptor
//
//  Created by Peter Kamb on 8/26/19.
//  Copyright © 2019 Feedback. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handle(event:replyEvent:)),
                                                     forEventClass: AEEventClass(kCoreEventClass),
                                                     andEventID: AEEventID(kAEOpenDocuments))
    }
    
    func open(urls: [URL]) {
        let additionalEvent = NSAppleEventDescriptor(eventClass:       AEEventClass(kCoreEventClass),
                                                     eventID:          AEEventID(kAEOpenDocuments),
                                                     targetDescriptor: NSAppleEventDescriptor(bundleIdentifier: Bundle.main.bundleIdentifier!),
                                                     returnID:         AEReturnID(kAutoGenerateReturnID),
                                                     transactionID:    AETransactionID(kAnyTransactionID))
        
        let directObject = NSAppleEventDescriptor(string: "MY_CUSTOM_APPLE_EVENT")
        additionalEvent.setDescriptor(directObject, forKeyword: keyDirectObject)
        
        NSWorkspace.shared.open(urls,
                                withAppBundleIdentifier: Bundle.main.bundleIdentifier!,
                                options: [.withErrorPresentation],
                                additionalEventParamDescriptor: additionalEvent,
                                launchIdentifiers: nil)
    }
    
    @objc func handle(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        guard let event = event else {
                return
        }
        print(event)
        
        guard let additionalEvent = event.paramDescriptor(forKeyword: keyAEPropData) else {
            return
        }
        print(additionalEvent)
        
        guard let directObject = additionalEvent.paramDescriptor(forKeyword: keyDirectObject) else {
            return
        }
        print(directObject)
    }
    
}

class ViewController: NSViewController {
    
    @IBAction func openFiles(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        guard openPanel.runModal() != .cancel else {
            return
        }
        (NSApplication.shared.delegate as! AppDelegate).open(urls: openPanel.urls)
    }
    
}
