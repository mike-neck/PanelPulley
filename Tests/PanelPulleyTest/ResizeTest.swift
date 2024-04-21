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
