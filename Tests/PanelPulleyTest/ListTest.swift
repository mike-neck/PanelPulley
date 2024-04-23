import CoreGraphics
import Foundation
import XCTest

@testable import pp

protocol PanelPulleyTestUtil {
}

class WindowListTest: XCTestCase, PanelPulleyTestUtil {
  func testInit_WithNil_ThenNil() {
    let windowList = WindowList(of: nil)
    XCTAssertNil(windowList, "init, with nil, then nil")
  }

  func testEmptyWindowList_ThenNil() throws {
    let windowList = try XCTUnwrap(WindowList(of: [] as NSArray as CFArray))
    let lines = windowList.makeOutputs()
    XCTAssertNil(lines, "empty windowList, then nil")
  }

  func testFilter_IsOnScreen_And_PositionY() throws {
    let input = [
      NSDictionary(
        id: 100,
        app: "app-1",
        title: "this will be selected",
        isOnScreen: true,
        visible: 2.0,
        rect: cfDictionary(
          width: 400,
          height: 300,
          x: 200,
          y: 200
        )
      ),
      NSDictionary(
        id: 101,
        app: "app-2",
        title: "this will be filtered out by isOnScreen",
        isOnScreen: false,
        visible: 2.0,
        rect: cfDictionary(
          width: 400,
          height: 300,
          x: 200,
          y: 25
        )
      ),
      NSDictionary(
        id: 102,
        app: "app-3",
        title: "this will be filtered out by y-axis",
        isOnScreen: true,
        visible: 2.0,
        rect: cfDictionary(
          width: 400,
          height: 300,
          x: 200,
          y: -1
        )
      ),
    ]
    let windowList = try! XCTUnwrap(WindowList(of: input as NSArray as CFArray))
    let lines: [String] = try XCTUnwrap(
      windowList.makeOutputs(), "filter, isOnScreen, y-axis")
    XCTAssertEqual(1, lines.count, "filter, isOnScreen, y-axis, result count \(lines)")
  }

  func testFilter_SortByIdAsc() throws {
    let input = [
      NSDictionary(
        id: 1000,
        app: "app-1",
        title: "this will be selected",
        isOnScreen: true,
        visible: 2.0,
        rect: cfDictionary(
          width: 400,
          height: 300,
          x: 200,
          y: 200
        )
      ),
      NSDictionary(
        id: 10000,
        app: "app-2",
        title: "this will be filtered out by isOnScreen",
        isOnScreen: true,
        visible: 2.0,
        rect: cfDictionary(
          width: 400,
          height: 300,
          x: 200,
          y: 25
        )
      ),
      NSDictionary(
        id: 100,
        app: "app-3",
        title: "this will be filtered out by y-axis",
        isOnScreen: true,
        visible: 2.0,
        rect: cfDictionary(
          width: 400,
          height: 300,
          x: 200,
          y: 100
        )
      ),
    ]
    let windowList = try! XCTUnwrap(WindowList(of: input as NSArray as CFArray))
    let lines: [String] = try XCTUnwrap(
      windowList.makeOutputs(), "filter, sort by id asc")
    XCTAssertEqual(3, lines.count, "filter, sort by id asc, has count 3")
    let ids = lines.compactMap {
      $0.trimmingCharacters(in: .whitespaces).split(separator: " ").first
    }.map { String($0) }
    let expectedIds = [
      "100", "1000", "10000",
    ]
    XCTAssertEqual(
      expectedIds, ids, "filter, sort by id asc, \(ids)")
  }
}

class ArrayExtensionTest: XCTestCase, PanelPulleyTestUtil {

  func testInit_WithNil_ThenNil() {
    let array: [NSDictionary]? = [NSDictionary](from: nil)
    XCTAssertNil(array, "init, with nil, then nil")
  }

  func testInit_WithEmpty_ThenNil() {
    let input: NSArray = []
    let array: [NSDictionary]? = [NSDictionary](from: input as CFArray)
    XCTAssertNil(array, "init, with empty, then nil")
  }

  func testInit_WithSingleElement_ThenSingleElement() {
    let input: [NSDictionary] = [
      NSDictionary(object: 101 as NSNumber as CFNumber, forKey: kCGWindowNumber as NSString)
    ]
    guard let array: [NSDictionary] = [NSDictionary](from: input as CFArray) else {
      XCTExpectFailure("expected not nil")
      return
    }
    XCTAssertEqual(input, array, "init, with single element, then single element")
  }

  private func string(_ str: CFString) -> String {
    return str as NSString as String
  }

  func testInit_WithMultipleElements_ThenTheSameSizeElements() {
    let input: [NSDictionary] = [
      NSDictionary(from: [
        kCGWindowNumber: 101
      ]),
      NSDictionary(from: [
        kCGWindowNumber: 102
      ]),
    ]
    guard let array: [NSDictionary] = [NSDictionary](from: input as CFArray) else {
      XCTExpectFailure("expected not nil")
      return
    }
    XCTAssertEqual(input, array, "init, with multiple elements, then the same size elements")
  }
}

class ItemTest: XCTestCase, PanelPulleyTestUtil {

  func testInit_WithEmptyDictionary_ThenNil() {
    let empty: [CFString: Any] = [:]
    let dict = NSDictionary(from: empty)
    let item = Item(dict)
    XCTAssertNil(item, "init, with empty dictionary, then nil")
  }

  func testInit_WithAllValues_ThenNotNil() {
    let rect = cfDictionary(width: 1000, height: 890, x: 15, y: 25)
    let dict = NSDictionary(
      id: 101,
      app: "XCTest",
      title: "CLion",
      isOnScreen: true,
      visible: 1.0,
      rect: rect
    )
    guard let item = Item(dict) else {
      XCTExpectFailure("expect item not nil")
      return
    }
    XCTAssertNotNil(item, "init, with all values, then not nil")
    XCTAssertEqual(101, item.id, "id")
    XCTAssertEqual("XCTest", item.app, "app")
    XCTAssertEqual("CLion", item.title, "title")
    XCTAssertEqual(true, item.isOnScreen, "isOnScreen")
    XCTAssertEqual(true, item.visible, "visible")
    XCTAssertEqual(Axis(x: 15, y: 25), item.minAxis, "min-axis")
    XCTAssertEqual(Axis(x: 15 + 1000, y: 25 + 890), item.maxAxis, "max-axis")
  }
}

extension NSDictionary {
  convenience init(
    id: Int?,
    app: String?,
    title: String?,
    isOnScreen: Bool?,
    visible: Float?,
    rect: CFDictionary?
  ) {
    var dict = [CFString: Any]()
    if let i = id { dict[kCGWindowNumber] = i }
    if let a = app { dict[kCGWindowOwnerName] = a }
    if let t = title { dict[kCGWindowName] = t }
    if let i = isOnScreen { dict[kCGWindowIsOnscreen] = i }
    if let v = visible { dict[kCGWindowAlpha] = v }
    if let r = rect { dict[kCGWindowBounds] = r }
    self.init(from: dict)
  }

  convenience init(from dict: [CFString: Any]) {
    let mutableDict = NSMutableDictionary()
    for (key, value) in dict {
      let k = key as NSString
      switch value {
      case let v as Bool:
        mutableDict.setObject(v as CFBoolean, forKey: k)
      case let v as Int:
        mutableDict.setObject(v as NSNumber as CFNumber, forKey: k)
      case let v as Float:
        mutableDict.setObject(v as NSNumber as CFNumber, forKey: k)
      case let v as String:
        mutableDict.setObject(v as NSString as CFString, forKey: k)
      case let d as CFDictionary:
        mutableDict.setObject(d, forKey: k)
      default:
        continue
      }
    }
    self.init(dictionary: mutableDict)
  }
}
