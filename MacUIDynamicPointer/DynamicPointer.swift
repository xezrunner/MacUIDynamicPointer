// MacUIDynamicPointer::DynamicPointer.swift - 23.05.2025
import AppKit

@Observable class DynamicPointerInfo {
    public var pointerLocation: CGPoint = .zero
    public var testString: String = ""
}

struct DynamicPointerElementInfo: Hashable, Equatable {
    init(description: String, axRole: String, position: CGPoint, size: CGSize) {
        self.description = description
        self.axRole = axRole
        self.position = position
        self.size = size
    }
    
    static func == (lhs: DynamicPointerElementInfo, rhs: DynamicPointerElementInfo) -> Bool {
        // FIXME: improve!
        lhs.position == rhs.position
    }
    
    private var id: UUID = UUID()
    
    public var description: String
    public var axRole: String
    public var position: CGPoint
    public var size: CGSize
}

@Observable class DynamicPointer {
    init() {
        registerForPointerEvents()
    }
    
    public func registerForPointerEvents() {
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
            self.handlePointerEvents(event: event)
            return event
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved], handler: handlePointerEvents(event:))
    }
    
    public var info: DynamicPointerInfo = DynamicPointerInfo()
    public var elementInfo: DynamicPointerElementInfo?
    
    public func handlePointerEvents(event: NSEvent) {
        info.pointerLocation = NSEvent.mouseLocation
        info.testString = getElementAtPoint(screenPoint: info.pointerLocation) ?? "nil"
    }
    
    private let systemWideElement = AXUIElementCreateSystemWide()
    
    private func getElementAtPoint(screenPoint: CGPoint) -> String? {
        // Convert screen coordinates (origin at bottom-left) to accessibility coordinates (origin at top-left):
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let point = CGPoint(x: screenPoint.x, y: screenHeight - screenPoint.y)
        
        var elementRef: AXUIElement?
        let result = AXUIElementCopyElementAtPosition(systemWideElement, Float(point.x), Float(point.y), &elementRef)

        guard result == .success, let element = elementRef else {
            elementInfo = nil
            return nil
        }
        
        let eInfo = DynamicPointerElementInfo(
            description: getStringAttribute(element, kAXDescriptionAttribute as CFString) ?? "",
            axRole:      getStringAttribute(element, kAXRoleAttribute as CFString) ?? "",
            position:    getPositionAttribute(element) ?? CGPoint.zero,
            size:        getSizeAttribute(element) ?? CGSize.zero
        )
        
        if elementInfo != eInfo { self.elementInfo = eInfo; }
        
        return elementInfo!.description
    }
    
    // MARK: - AX attribute helpers:
    
    private func getStringAttribute(_ element: AXUIElement, _ attribute: CFString) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        
        guard result == .success else { return nil }
        guard let cfString = value, CFGetTypeID(cfString) == CFStringGetTypeID() else { return nil }
        return cfString as? String
    }
    
    private func getBoolAttribute(_ element: AXUIElement, _ attribute: CFString) -> Bool? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute, &value)
        
        guard result == .success, let boolValue = value as? Bool else { return nil }
        return boolValue
    }
    
    private func getPositionAttribute(_ element: AXUIElement) -> CGPoint? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &value)
        
        guard result == .success, let axValue = value else { return nil }
        
        var point = CGPoint.zero
        if AXValueGetValue(axValue as! AXValue, .cgPoint, &point) { return point }
        return nil
    }
    
    private func getSizeAttribute(_ element: AXUIElement) -> CGSize? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &value)
        
        guard result == .success, let axValue = value else { return nil }
        
        var size = CGSize.zero
        if AXValueGetValue(axValue as! AXValue, .cgSize, &size) { return size }
        
        return nil
    }
}
