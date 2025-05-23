// MacUIDynamicPointer::DynamicPointer.swift - 23.05.2025
import AppKit

@Observable class DynamicPointerInfo {
    public var pointerLocation: CGPoint = .zero
    public var testString: String = ""
}

struct DynamicPointerElementInfo: Hashable, Equatable {
    init(enabled: Bool, description: String, axRole: String, origin: CGPoint, size: CGSize) {
        self.enabled = enabled
        self.description = description
        self.axRole = axRole
        self.position = CGPoint(x: origin.x + (size.width / 2), y: origin.y + (size.height / 2)) // center
        self.size = size
    }
    
    static func == (lhs: DynamicPointerElementInfo, rhs: DynamicPointerElementInfo) -> Bool {
        // FIXME: improve!
        lhs.position == rhs.position
    }
    
    private var id: UUID = UUID()
    
    public var enabled: Bool
    public var description: String
    public var axRole: String
    public var position: CGPoint
    public var size: CGSize
    
    static let EligiblilityList = [ "AXButton", "AXMenuBarItem", "AXPopUpButton", "AXDockItem", "AXMenuButton", "AXRadioButton" ]
    var isEligibleForDynamicPointer: Bool { enabled && DynamicPointerElementInfo.EligiblilityList.contains(axRole) }
}

@Observable class DynamicPointer {
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
            enabled:     getBoolAttribute(element, kAXEnabledAttribute as CFString) ?? false,
            description: getStringAttribute(element, kAXDescriptionAttribute as CFString) ?? "",
            axRole:      getStringAttribute(element, kAXRoleAttribute as CFString) ?? "",
            origin:      getPositionAttribute(element) ?? CGPoint.zero,
            size:        getSizeAttribute(element) ?? CGSize.zero
        )
        
        print(getStringAttribute(element, kAXHeaderAttribute as CFString) ?? "none")
        
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
