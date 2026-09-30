// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCUITestFramework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "XCUITestFramework",
            targets: ["XCUITestFramework"]),
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .target(
            name: "XCUITestFramework",
            dependencies: [],
            path: "XCUITestFramework"),
        .testTarget(
            name: "XCUITestFrameworkTests",
            dependencies: ["XCUITestFramework"],
            path: "XCUITestFrameworkTests"),
    ]
)
