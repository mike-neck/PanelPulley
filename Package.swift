// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PanelPulley",
    products: [
        .executable(name: "pp", targets: ["pp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "pp",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("version.txt"),
            ]
        ),
        .testTarget(
            name: "PanelPulleyTest",
            dependencies: [
                "pp",
            ]
        ),
    ]
)
