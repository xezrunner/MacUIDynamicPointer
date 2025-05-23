// MacUIDynamicPointer::MacUIDynamicPointerApp.swift - 23.05.2025

import SwiftUI

@main
struct MacUIDynamicPointerApp: App {
    var state = State()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
        }
    }
}

