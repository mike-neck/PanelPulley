import ApplicationServices
import ArgumentParser
import CoreGraphics
import Darwin
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
    help:
      "Specifies the width of the target window, either width or height or x-axis or y-axis is required."
  )
  var width: Int = -1

  @Option(
    name: [.customLong("height"), .customShort("h")],
    help:
      "Specifies the height of the target window, either width or height or x-axis or y-axis is required."
  )
  var height: Int = -1

  @Option(
    name: [.customLong("x-axis"), .customShort("x")],
    help:
      "Specifies the x-axis of the target window, either x-a or height or x-axis or y-axis is required."
  )
  var xAxis: Int = -1

  @Option(
    name: [.customLong("y-axis"), .customShort("y")],
    help:
      "Specifies the height of the target window, either width or height or x-axis or y-axis is required."
  )
  var yAxis: Int = -1

  @Option(
    name: [.customLong("verbose"), .customShort("v")],
    help: "Prints debug logs"
  )
  var verbose: Bool = false

  func matchingWindowId() -> ([String: Any]) -> Bool {
    let windowId = self.windowId
    return { win in
      guard let id = win[kCGWindowNumber as String] as? Int else {
        return false
      }
      return windowId == id
    }
  }

  var all: [Int] {
    return [
      width,
      height,
      xAxis,
      yAxis,
    ]
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

  private var _debug: Bool {
    let env = ResizeEnv(self.verbose)
    return env.isDebug
  }

  private static let SIZE: CFString = kAXSizeAttribute as CFString
  private static let POSITION: CFString = kAXPositionAttribute as CFString

  mutating func run() throws {
    if _debug {
      fputs("options: \(self)\n", stderr)
    }
    guard
      let list = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID)
        as? [[String: Any]]
    else {
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
      let window = uiElements.first
    else {
      throw ValidationError("Unable to retrieve the window for the given ID[\(self.windowId)]")
    }

    try changeRectOf(window)
  }

  func changeRectOf(_ window: AXUIElement) throws {
    guard let currentWindowSize: CGSize = window.getCurrentWindowSize() else {
      throw ValidationError(
        "Unable to retrieve the size of the window for the given ID[\(self.windowId)]")
    }
    guard let currentWindowPosition = window.getCurrentWindowPosition() else {
      throw ValidationError(
        "Unable to retrieve the position of the window for the given ID[\(self.windowId)]")
    }

    // try changing position first, because changing the window size is affected by the window position and the display size.
    if var windowPosition = calculateNewPosition(from: currentWindowPosition),
      let position = AXValueCreate(.cgPoint, &windowPosition)
    {
      let err = AXUIElementSetAttributeValue(window, Resize.POSITION, position)
      if _debug {
        fputs(
          "[err:\(err)]set position: \(currentWindowPosition): \(windowPosition) -> \(window.getCurrentWindowPosition()) \n",
          stderr)
      }
    }

    if var windowSize = calculateNewSize(from: currentWindowSize),
      let size = AXValueCreate(.cgSize, &windowSize)
    {
      let err = AXUIElementSetAttributeValue(window, Resize.SIZE, size)
      if _debug {
        fputs(
          "[err:\(err)]set size: \(currentWindowSize): \(windowSize) -> \(window.getCurrentWindowSize()) \n",
          stderr)
      }
    }
  }

  func calculateNewSize(from currentWindowSize: CGSize) -> CGSize? {
    if self.width == -1 && self.height == -1 {
      return nil
    }
    let newWidth = self.width == -1 ? currentWindowSize.width : CGFloat(self.width)
    let newHeight = self.height == -1 ? currentWindowSize.height : CGFloat(self.height)
    return CGSize(width: newWidth, height: newHeight)
  }

  func calculateNewPosition(from currentPoint: CGPoint) -> CGPoint? {
    if self.xAxis == -1 && self.yAxis == -1 {
      return nil
    }
    let x = xAxis == -1 ? currentPoint.x : CGFloat(xAxis)
    let y = yAxis == -1 ? currentPoint.y : CGFloat(yAxis)
    return CGPoint(x: x, y: y)
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

  func getCurrentWindowPosition() -> CGPoint? {
    var axPosition: AnyObject?
    if .success
      != AXUIElementCopyAttributeValue(self, kAXPositionAttribute as CFString, &axPosition)
    {
      return nil
    }
    switch axPosition {
    case is AXValue:
      break
    default:
      return nil
    }
    let position = axPosition as! AXValue
    var pos = CGPoint()
    if !AXValueGetValue(position, .cgPoint, &pos) {
      return nil
    }
    return pos
  }
}

struct ResizeEnv {
  let verbose: Bool
  let env: [String: String]

  init(_ verbose: Bool) {
    self.init(verbose, ProcessInfo.processInfo.environment)
  }

  init(_ verbose: Bool, _ env: [String: String]) {
    self.verbose = verbose
    self.env = env
  }

  var isDebug: Bool {
    return verbose || env["DEBUG"] != nil
  }
}
