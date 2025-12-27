// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftWebGL",
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", from: "0.37.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftWebGL",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
            ],
        ),
    ],
)
