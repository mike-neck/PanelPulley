// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct PanelPulley: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pp",
        abstract: "Window utility",
        usage: "manipulates windows.",
        subcommands: [
            List.self,
            Resize.self,
        ],
        defaultSubcommand: List.self
    )
}
