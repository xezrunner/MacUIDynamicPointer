// MacUIDynamicPointer::ContentView.swift - 23.05.2025

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        let hasAXPermissions = appState.accessibilityPermissionState ?? AXIsProcessTrusted()
        
        if !hasAXPermissions { AXPermissionsView() }
        else                 { DebugView() }
    }
}

struct DebugView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        let elementInfo = appState.dynamicPointer.elementInfo
        
        VStack {
            Text(elementInfo.debugDescription)
                .monospaced()
            
            Button("Test") {}
            Button("Test 2") {}
        }
        .padding()
        .onChange(of: elementInfo) { oldValue, newValue in
            if newValue?.axRole == "AXButton" {
                
            }
            else {
                
            }
        }
    }
}

struct AXPermissionsView: View {
    @Environment(AppState.self) private var appState
    
    // FIXME: What happens when the accessibility permission is suddenly taken away? How would we know?
    
    var body: some View {
        VStack {
            Text("Accessibility permissions are required").font(.title)
            Text("These permissions will be used to gather information about UI elements on screen.").font(.title3)
            
            Button(appState.accessibilityPermissionState != nil ? "Check permissions" : "Grant permissions", action: promptForPermission)
                .buttonStyle(.borderedProminent)
                .padding([.horizontal, .top])
        }
        .padding()
    }
    
    func promptForPermission() {
        let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options: NSDictionary = [prompt: true]
        appState.accessibilityPermissionState = AXIsProcessTrustedWithOptions(options)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
