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
    
    let appleEventText = "MY_CUSTOM_APPLE_EVENT"
    
    func open(urls: [URL]) {
        
        let additionalEvent = NSAppleEventDescriptor(string: appleEventText)
        
        /*
         * Open the URLs, passing the `additionalEventParamDescriptor:` Apple Event
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
        
        guard let event = event else { fatalError() }
        print(event)
        
        /*
         * This Apple Event **should** also contain the `additionalEventParamDescriptor:` Apple Event.
         * The additional event should be added to the system event under the key keyAEPropData / 'prdt'.
         */
        
        if let additionalEvent = event.paramDescriptor(forKeyword: keyAEPropData) {
            /*
             * ##################################################################
             * In this case, the `additionalEventParamDescriptor:` Apple Event was passed correctly.
             * ##################################################################
             */
            
            print(additionalEvent)
            
            if  additionalEvent.stringValue == appleEventText {
                print("additionalEventParamDescriptor: Apple Event was passed and handled correctly :)")
            } else {
                print("additionalEventParamDescriptor: Apple Event was found, but contained the wrong value...?")
            }
        } else {
            
            /*
             * ##################################################################
             * Put a breakpoint here! This is the bug.
             * `additionalEventParamDescriptor:` parameter was not passed.
             * ##################################################################
             */
            
            print("event for additionalEventParamDescriptor: not found!")
        }
        
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
