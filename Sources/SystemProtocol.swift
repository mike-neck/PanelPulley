import Darwin

protocol SystemProtocol {
  func write(stdout text: String)
  func write(stderr text: String)

  static var ofDefault: SystemProtocol { get }
}

class System: SystemProtocol {
  static var ofDefault: SystemProtocol {
    defaultSystem
  }

  func write(stdout text: String) {
    fputs("\(text)\n", stdout)
  }

  func write(stderr text: String) {
    fputs("\(text)\n", stderr)
  }
}

private let defaultSystem: System = System()
