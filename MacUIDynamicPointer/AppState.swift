// MacUIDynamicPointer::State.swift - 23.05.2025
import Foundation

@Observable class AppState {
    var accessibilityPermissionState: Bool?
    var dynamicPointer: DynamicPointer = DynamicPointer()
}
