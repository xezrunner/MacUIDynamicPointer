// MacUIDynamicPointer::ContentView.swift - 23.05.2025

import SwiftUI

struct ContentView: View {
    @Environment(State.self) private var state
    
    var body: some View {
        let hasAXPermissions = state.accessibilityPermissionState ?? AXIsProcessTrusted()
        
        if !hasAXPermissions { AXPermissionsView() }
        else                 { DebugView() }
    }
}

struct DebugView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct AXPermissionsView: View {
    @Environment(State.self) private var state
    
    // FIXME: What happens when the accessibility permission is suddenly taken away? How would we know?
    
    var body: some View {
        VStack {
            Text("Accessibility permissions are required").font(.title)
            Text("These permissions will be used to gather information about UI elements on screen.").font(.title3)
            
            Button(state.accessibilityPermissionState != nil ? "Check permissions" : "Grant permissions", action: promptForPermission)
                .buttonStyle(.borderedProminent)
                .padding([.horizontal, .top])
        }
        .padding()
    }
    
    func promptForPermission() {
        let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options: NSDictionary = [prompt: true]
        state.accessibilityPermissionState = AXIsProcessTrustedWithOptions(options)
    }
}

#Preview {
    ContentView()
        .environment(State())
}
