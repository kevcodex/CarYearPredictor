// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scrapper",
    dependencies: [
        .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "4.0.0"),
        .package(url: "https://github.com/kevcodex/MiniNe", from: "1.0.0"),
        .package(url: "https://github.com/kevcodex/ScriptHelpers", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Run",
            dependencies: ["App"]),
        .target(
            name: "App",
            dependencies: ["Kanna", "MiniNe", "ScriptHelpers"]),
        .testTarget(
            name: "ScrapperTests",
            dependencies: ["App"]),
    ]
)
