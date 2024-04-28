// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct PanelPulley: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "ppl",
    abstract: "Window utility",
    usage: "manipulates windows.",
    version: appVersion,
    subcommands: [
      List.self,
      Resize.self,
    ],
    defaultSubcommand: List.self
  )
}

extension PanelPulley {
  static var appVersion: String {
    guard
      let file = Bundle.module.url(forResource: "version", withExtension: "txt"),
      let text: String = file.text
    else {
      return "u0.0.0"
    }
    return text.replacingOccurrences(of: "\n", with: "")
  }
}

extension URL {
  var text: String? {
    do {
      return try String(contentsOf: self)
    } catch {
      return nil
    }
  }
}
