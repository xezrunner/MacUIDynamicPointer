// MacUIDynamicPointer::MacUIDynamicPointerApp.swift - 23.05.2025

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    public var appState = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }
}

@main
struct MacUIDynamicPointerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appDelegate.appState)
        }
    }
}

