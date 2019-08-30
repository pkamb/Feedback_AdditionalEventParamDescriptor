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
        
        /*
         * Set a handler for the Apple Event that will be sent by NSWorkspace `open(urls: ...)`
         */
        
        NSAppleEventManager.shared().setEventHandler(self,
                                                     andSelector: #selector(handle(event:replyEvent:)),
                                                     forEventClass: AEEventClass(kCoreEventClass),
                                                     andEventID: AEEventID(kAEOpenDocuments))
    }
    
    func open(urls: [URL]) {
        
        /*
         * Create an event to be passed as the `additionalEventParamDescriptor:`
         * of the NSWorkspace `open(urls: ...)` function call.
         */
        
        let additionalEvent = NSAppleEventDescriptor(eventClass:       AEEventClass(kCoreEventClass),
                                                     eventID:          AEEventID(kAEOpenDocuments),
                                                     targetDescriptor: NSAppleEventDescriptor(bundleIdentifier: Bundle.main.bundleIdentifier!),
                                                     returnID:         AEReturnID(kAutoGenerateReturnID),
                                                     transactionID:    AETransactionID(kAnyTransactionID))
        
        /*
         * Set your custom data as an Apple Event packed into the `directObject`
         * of the `additionalEventParamDescriptor:` event.
         */
        
        let directObject = NSAppleEventDescriptor(string: "MY_CUSTOM_APPLE_EVENT")
        additionalEvent.setDescriptor(directObject, forKeyword: keyDirectObject)
        
        /*
         * Open the URLs, passing the `additionalEventParamDescriptor:`
         */
        
        NSWorkspace.shared.open(urls,
                                withAppBundleIdentifier: Bundle.main.bundleIdentifier!,
                                options: [.withErrorPresentation],
                                additionalEventParamDescriptor: additionalEvent,
                                launchIdentifiers: nil)
    }
    
    @objc func handle(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        
        /*
         * Handle the Apple Event sent by NSWorkspace `open(urls: ...)`
         *
         * The system-sent Apple Event will contain a 'bmrk' Apple Event for each file URL you open.
         *
         * If an `additionalEventParamDescriptor:` Apple Event was added to the NSWorkspace function call,
         * that additional event should be merged with the system event.
         */
        
        guard let event = event else {
            print("event not found!")
            return
        }
        print(event)
        
        /*
         * This Apple Event **should** also contain the `additionalEventParamDescriptor:` Apple Event.
         * The additional event should be merged into this event under the key keyAEPropData / 'prdt'.
         */
        
        guard let additionalEvent = event.paramDescriptor(forKeyword: keyAEPropData) else {
            
            /*
             * ##################################################################
             * Put a breakpoint here! This is the bug. `additionalEventParamDescriptor:` parameter was not passed.
             * ##################################################################
             */
            
            print("event for additionalEventParamDescriptor: not found!")
            return
        }
        print(additionalEvent)
        
        /*
         * We set the custom-data Apple Event as the direct object of the additional event.
         */
        
        guard let directObject = additionalEvent.paramDescriptor(forKeyword: keyDirectObject) else {
            print("direct object of additionalEventParamDescriptor: not found!")
            return
        }
        print(directObject)
        
        /*
         * ##################################################################
         * In this case, the `additionalEventParamDescriptor:` Apple Event was passed correctly.
         * ##################################################################
         */
        
        print("additionalEventParamDescriptor: Apple Event was passed and handled correctly :)")
    }
    
}

class ViewController: NSViewController {
    
    @IBAction func openFiles(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        guard openPanel.runModal() != .cancel else {
            return
        }
        (NSApplication.shared.delegate as! AppDelegate).open(urls: openPanel.urls)
    }
    
}

extension FourCharCode: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        let value = (value.utf8.count == 4) ? value : "????"
        self = value.utf8.reduce(0, {$0 << 8 + FourCharCode($1)} )
    }
    
}
