import ApplicationServices
import ArgumentParser
import CoreGraphics
import Foundation

struct Resize: ParsableCommand {
    
    @Option(
        name: [
            .customLong("target-window"),
            .customLong("target"),
            .customLong("window"),
            .customShort("t"),
        ],
        help: "An ID for the target window, required."
    )
    var windowId: Int = -1
    
    @Option(
        name: [.customLong("width"), .customShort("w")],
        help: "Specifies the width of the target window, either width or height or x-axis or y-axis is required."
    )
    var width: Int = -1
    
    @Option(
        name: [.customLong("height"), .customShort("h")],
        help: "Specifies the height of the target window, either width or height or x-axis or y-axis is required."
    )
    var height: Int = -1
    
    @Option(
        name: [.customLong("x-axis"), .customShort("x")],
        help: "Specifies the x-axis of the target window, either x-a or height or x-axis or y-axis is required."
    )
    var xAxis: Int = -1
    
    @Option(
        name: [.customLong("y-axis"), .customShort("y")],
        help: "Specifies the height of the target window, either width or height or x-axis or y-axis is required."
    )
    var yAxis: Int = -1
    
    func matchingWindowId() -> ([String: Any]) -> Bool {
        let windowId = self.windowId
        return { win in
            guard let id = win[kCGWindowNumber as String] as? Int32 else {
                return false
            }
            return windowId == id
        }
    }
    
    var all: [Int] {
        get {
            return [
                width,
                height,
                xAxis,
                yAxis,
            ]
        }
    }
    
    func allSatisfies(_ condition: (Int) -> Bool) -> Bool {
        let all = self.all
        return all.filter(condition).count == all.count
    }
    
    mutating func validate() throws {
        if allSatisfies({ $0 == -1 }) {
            throw ValidationError("Either 'width' or 'height' or 'x-axis' or 'y-axis' is required.")
        }
    }
    
    mutating func run() throws {
        guard let list = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as? [[String: Any]] else {
            throw ValidationError("No windows found.")
        }
        guard let winInfo = list.filter(matchingWindowId()).first else {
            throw ValidationError("Window with the given ID[\(self.windowId)] is not found.")
        }
        
        guard let pid = winInfo[kCGWindowOwnerPID as String] as? pid_t else {
            throw ValidationError("Unable to retrieve the Process ID for the given ID[\(self.windowId)]")
        }
        
        let appRef = AXUIElementCreateApplication(pid)
        
        guard let uiElements = appRef.copyAttributeValue(),
              let window = uiElements.first else {
            throw ValidationError("Unable to retrieve the window for the given ID[\(self.windowId)]")
        }
        
        try changeWindowSize(window)
    }
    
    func changeWindowSize(_ window: AXUIElement) throws {
        guard let currentWindowSize: CGSize = window.getCurrentWindowSize() else {
            throw ValidationError("Unable to retrieve the size of the window for the given ID[\(self.windowId)]")
        }

        guard let windowSize = calculateNewSize(from: currentWindowSize) else {
            throw ValidationError("Unable to set the window size for the given ID[\(self.windowId)]")
        }
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, windowSize)
    }

    func calculateNewSize(from currentWindowSize: CGSize) -> AXValue? {
        let newWidth = self.width == -1 ? currentWindowSize.width : CGFloat(self.width)
        let newHeight = self.height == -1 ? currentWindowSize.height : CGFloat(self.height)

        var newSize: CGSize = CGSize(width: newWidth, height: newHeight)
        return AXValueCreate(.cgSize, &newSize)
    }
}

extension AXUIElement {
    func copyAttributeValue() -> [AXUIElement]? {
        var window: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, kAXWindowsAttribute as CFString, &window)
        if result != .success {
            return nil
        }
        guard let attributes = window as? [AXUIElement] else {
            return nil
        }
        return attributes
    }

    func getCurrentWindowSize() -> CGSize? {
        var axSizeValue: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, kAXSizeAttribute as CFString, &axSizeValue)
        if result != .success {
            return nil
        }
        switch axSizeValue {
        case is AXValue:
            break
        default:
            return nil
        }
        let sizeValue = axSizeValue as! AXValue
        var size = CGSize()
        if !AXValueGetValue(sizeValue, .cgSize, &size) {
            return nil
        }
        return size
    }
}
