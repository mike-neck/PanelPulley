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

  func createValuedResize(
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

  func createNoOptionResize(exceptFor option: ResizeOption = .nothing) -> Resize {
    var resize = createValuedResize(width: -1, height: -1, xAxis: -1, yAxis: -1)
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
      createValuedResize(width: -1),
      createValuedResize(height: -1),
      createValuedResize(xAxis: -1),
      createValuedResize(yAxis: -1),
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
      createNoOptionResize(exceptFor: .width(400)),
      createNoOptionResize(exceptFor: .height(400)),
      createNoOptionResize(exceptFor: .xAxis(400)),
      createNoOptionResize(exceptFor: .yAxis(400)),
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
    var resize = createValuedResize(width: -1, height: -1, xAxis: -1, yAxis: -1)
    XCTAssertThrowsError(
      try resize.validate(),
      "validate, with all option being -1, throws error"
    )
  }
}
