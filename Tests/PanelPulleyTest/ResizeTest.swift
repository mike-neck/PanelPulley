import Foundation
import XCTest

@testable import pp

class ResizeEnvTest: XCTestCase {
  func testIsDebug_WhenVerboseTrue_ReturnsTrue() {
    let env = ResizeEnv(true, [:])
    XCTAssertTrue(env.isDebug, "isDebug, verbose = true, isDebug = true")
  }
  func testIsDebug_WhenEnvHasDEBUG_ReturnsTrue() {
    let env = ResizeEnv(false, ["DEBUG": "true"])
    XCTAssertTrue(env.isDebug, "isDebug, verbose = false + env[DEBUG] = true, isDebug = true")
  }
  func testIsDebug_WhenNoVerbose_WhenEnvHasNoDEBUG_ReturnsFalse() {
    let env = ResizeEnv(false, [:])
    XCTAssertFalse(
      env.isDebug,
      "isDebug, verbose = false + no env[DEBUG], isDebug = false \(env): \(env.verbose) || \(env.env["DEBUG"] ?? "<nil>") != nil -> isDebug=[\(env.isDebug)]"
    )
  }
}

class ResizeTest: XCTestCase {

  static func createValuedResize(
    width: Int = 100,
    height: Int = 100,
    xAxis: Int = 100,
    yAxis: Int = 100
  ) -> Resize {
    var resize = Resize()
    resize.width = width
    resize.height = height
    resize.xAxis = xAxis
    resize.yAxis = yAxis
    return resize
  }

  enum ResizeOption {
    case width(_ value: Int)
    case height(_ value: Int)
    case xAxis(_ value: Int)
    case yAxis(_ value: Int)

    case nothing

  }

  static func createNoOptionResize(exceptFor option: ResizeOption = .nothing) -> Resize {
    var resize = ResizeTest.createValuedResize(width: -1, height: -1, xAxis: -1, yAxis: -1)
    switch option {
    case .width(let width):
      resize.width = width
    case .height(let height):
      resize.height = height
    case .xAxis(let xAxis):
      resize.xAxis = xAxis
    case .yAxis(let yAxis):
      resize.yAxis = yAxis
    case .nothing: break
    }
    return resize
  }

  func testValidate_WithNotAllOptionBeingMinus1_ThrowsNoError() throws {
    let resizes: [Resize] = [
      ResizeTest.createValuedResize(width: -1),
      ResizeTest.createValuedResize(height: -1),
      ResizeTest.createValuedResize(xAxis: -1),
      ResizeTest.createValuedResize(yAxis: -1),
    ]
    for r in resizes {
      var resize = r
      XCTAssertNoThrow(
        try resize.validate(),
        "validate, with not all option being -1, throws no error"
      )
    }
  }

  func testValidate_WithAnyHavingOption_ThrowsNoError() throws {
    let resizes: [Resize] = [
      ResizeTest.createNoOptionResize(exceptFor: .width(400)),
      ResizeTest.createNoOptionResize(exceptFor: .height(400)),
      ResizeTest.createNoOptionResize(exceptFor: .xAxis(400)),
      ResizeTest.createNoOptionResize(exceptFor: .yAxis(400)),
    ]
    for r in resizes {
      var resize = r
      XCTAssertNoThrow(
        try resize.validate(),
        "validate, with not all option being -1, throws no error"
      )
    }
  }

  func testValidate_WithAllOptionBeingMinus1_ThrowsError() {
    var resize = ResizeTest.createValuedResize(width: -1, height: -1, xAxis: -1, yAxis: -1)
    XCTAssertThrowsError(
      try resize.validate(),
      "validate, with all option being -1, throws error"
    )
  }
}

class MatchingWindowIdTest: XCTestCase {
  static let window = [
    kCGWindowNumber as String: 100 as Int
  ]

  func testMatchingCase() {
    var resize = ResizeTest.createNoOptionResize()
    resize.windowId = 100
    let predicate: ([String: Any]) -> Bool = resize.matchingWindowId()
    XCTAssertTrue(
      predicate(MatchingWindowIdTest.window),
      "matching, resize[100], window[100] -> true\nresize:\(resize), window:\(MatchingWindowIdTest.window) -> predicate:\(String(describing: predicate)) -> result:\(predicate(MatchingWindowIdTest.window))\n--------\n\n"
    )
  }

  func testNotMatchingCase() {
    var resize = Resize()
    resize.windowId = 101
    let predicate: ([String: Any]) -> Bool = resize.matchingWindowId()
    XCTAssertFalse(
      predicate(MatchingWindowIdTest.window),
      "matching, resize[100], window[101] -> false"
    )
  }

  func testNoIdCase() {
    var resize = Resize()
    resize.windowId = 100
    let predicate: ([String: Any]) -> Bool = resize.matchingWindowId()
    XCTAssertFalse(
      predicate([:]),
      "matching, resize[100], [:] -> false"
    )
  }

  func testInvalidIdTypeCase() {
    var resize = Resize()
    resize.windowId = 100
    let predicate: ([String: Any]) -> Bool = resize.matchingWindowId()
    XCTAssertFalse(
      predicate([kCGWindowNumber as String: "invalid id case"]),
      "matching, resize[100], window[String] -> false"
    )
  }
}

class CalculateNewSizeTest: XCTestCase {

  func test_WithDefaultValue_ThenNil() {
    let resize = ResizeTest.createNoOptionResize()
    let current = CGSize(width: 100.0, height: 100.0)
    XCTAssertNil(
      resize.calculateNewSize(from: current),
      "calculateNewSize, [w:-1,h:-1], nil"
    )
  }

  func test_WithWidthGiven_ThenNotNil() throws {
    let resize = ResizeTest.createNoOptionResize(exceptFor: .width(20))
    let current = CGSize(width: 100.0, height: 100.0)
    let newSize = try XCTUnwrap(
      resize.calculateNewSize(from: current),
      "calculateNewSize, [w:20,h:-1], not nil"
    )
    XCTAssertEqual(
      CGSize(width: 20.0, height: 100.0),
      newSize,
      "calculateNewSize, [w:20,h:-1]/[w:100,h:100], [w:20,h:100]"
    )
  }

  func test_WithHeightGiven_ThenNotNil() throws {
    let resize = ResizeTest.createNoOptionResize(exceptFor: .height(20))
    let current = CGSize(width: 100.0, height: 100.0)
    let newSize = try XCTUnwrap(
      resize.calculateNewSize(from: current),
      "calculateNewSize, [w:-1,h:20], not nil"
    )
    XCTAssertEqual(
      CGSize(width: 100.0, height: 20.0),
      newSize,
      "calculateNewSize, [w:-1,h:20]/[w:100,h:100], [w:100,h:20]"
    )
  }
}

class CalculateNewPositionTest: XCTestCase {

  func test_WithDefaultValue_ThenNil() {
    let resize = ResizeTest.createNoOptionResize()
    let current = CGPoint(x: 40.0, y: 30.0)
    XCTAssertNil(
      resize.calculateNewPosition(from: current),
      "calculateNewPosition, [x:-1,y:-1], nil"
    )
  }

  func test_WithXAxisGiven_ThenNotNil() throws {
    let resize = ResizeTest.createNoOptionResize(exceptFor: .xAxis(100))
    let current = CGPoint(x: 40.0, y: 30.0)
    let newPosition = resize.calculateNewPosition(from: current)
    XCTAssertNotNil(
      newPosition,
      "calculateNewPosition, [x:100,y:-1], not nil"
    )
    let position = try XCTUnwrap(newPosition)
    XCTAssertEqual(
      CGPoint(x: 100.0, y: 30.0),
      position,
      "calculateNewPosition, input:[x:100,y:-1], current:[x:40,y:30] -> [x:100,y:30]"
    )
  }

  func test_WithYAxisGiven_ThenNotNil() throws {
    let resize = ResizeTest.createNoOptionResize(exceptFor: .yAxis(100))
    let current = CGPoint(x: 40.0, y: 30.0)
    let newPosition = resize.calculateNewPosition(from: current)
    XCTAssertNotNil(
      newPosition,
      "calculateNewPosition, [x:-1,y:100], not nil"
    )
    let position = try XCTUnwrap(newPosition)
    XCTAssertEqual(
      CGPoint(x: 40.0, y: 100.0),
      position,
      "calculateNewPosition, input:[x:-1,y:100], current:[x:40,y:30] -> [x:40,y:100]"
    )
  }

  func test_WithBothGiven_ThenNotNil() throws {
    var resize = ResizeTest.createNoOptionResize()
    resize.yAxis = 100
    resize.xAxis = 200
    let current = CGPoint(x: 40.0, y: 30.0)
    let newPosition = resize.calculateNewPosition(from: current)
    XCTAssertNotNil(
      newPosition,
      "calculateNewPosition, [x:200,y:100], not nil"
    )
    let position = try XCTUnwrap(newPosition)
    XCTAssertEqual(
      CGPoint(x: 200.0, y: 100.0),
      position,
      "calculateNewPosition, input:[x:200,y:100], current:[x:40,y:30] -> [x:200,y:100]"
    )
  }
}
