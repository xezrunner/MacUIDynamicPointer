// MacUIDynamicPointer::MacUIDynamicPointerApp.swift - 23.05.2025

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    public var appState = AppState()
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let screen = NSScreen.main!
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        
        let contentView = OverlayView().environment(appState)
        window.contentView = NSHostingView(rootView: contentView)
        
        window.isOpaque = false
        window.backgroundColor = .clear
        
        window.level = .popUpMenu
        window.ignoresMouseEvents = true
        
        window.makeKeyAndOrderFront(nil)
    }
}

struct CursorVisualInfo {
    var hasElement: Bool = false
    
    var position: CGPoint = .zero
    var size:     CGSize  = .zero
}

struct OverlayView: View {
    @Environment(AppState.self) private var appState
    
    @State var pointerPosition: CGPoint = .zero
    let defaultPointerSize = CGSize(width: 24, height: 24)
    let mainScreenFrame = NSScreen.main?.frame ?? .zero
    
    func getCursorVisualInfo() -> CursorVisualInfo {
        var info = CursorVisualInfo()
        let elementInfo = appState.dynamicPointer.elementInfo
        
        if elementInfo != nil && elementInfo!.isEligibleForDynamicPointer { // TODO: where should we decide about axRole?
            info.hasElement = true
            info.position = elementInfo!.position
            info.size     = elementInfo!.size
//            if info.size.height == 52.0 {
//                info.size.height = 32.0
//            }
        } else {
            info.position = CGPoint(x: pointerPosition.x, y: mainScreenFrame.height - pointerPosition.y)
            info.size = defaultPointerSize
        }
        
        return info
    }
    
    func getRoundedRadiusForVisualInfo(visualInfo: CursorVisualInfo) -> CGFloat {
        if !visualInfo.hasElement { return 24 }
        return min(visualInfo.size.width, visualInfo.size.height) * 0.2
    }
    
    var body: some View {
        ZStack {
//            Color.black.opacity(0.1)
            
            let visualInfo = getCursorVisualInfo()
            
            RoundedRectangle(cornerRadius: getRoundedRadiusForVisualInfo(visualInfo: visualInfo), style: .circular)
                .fill(.secondary).opacity(0.5)
            
                .frame(width: visualInfo.size.width, height: visualInfo.size.height)
                .position(visualInfo.position)
                .opacity(visualInfo.hasElement ? 1 : 0)
            
                .animation(.smooth(duration: 0.5), value: visualInfo.size)
                .animation(.smooth(duration: 0.35), value: visualInfo.position)
                .animation(.linear(duration: 0.2), value: visualInfo.hasElement)
            
                .onChange(of: visualInfo.hasElement) { oldValue, newValue in
                    if newValue { NSCursor.hide()   }
                    else        { NSCursor.unhide() }
                }
        }
        .onAppear() {
            NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
                appState.dynamicPointer.handlePointerEvents(event: event)
                pointerPosition = NSEvent.mouseLocation
                return event
            }
            NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { event in
                appState.dynamicPointer.handlePointerEvents(event: event)
                pointerPosition = NSEvent.mouseLocation
            }
        }
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

