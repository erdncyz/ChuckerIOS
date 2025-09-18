// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChuckerIOS",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ChuckerIOS",
            targets: ["ChuckerIOS"]
        ),
        .executable(
            name: "TestApp",
            targets: ["TestApp"]
        ),
    ],
    dependencies: [
        // No external dependencies for now - keeping it lightweight
    ],
    targets: [
        .target(
            name: "ChuckerIOS",
            dependencies: [],
            path: "Sources/ChuckerIOS"
        ),
        .executableTarget(
            name: "TestApp",
            dependencies: ["ChuckerIOS"],
            path: "TestApp"
        ),
        .testTarget(
            name: "ChuckerIOSTests",
            dependencies: ["ChuckerIOS"],
            path: "Tests/ChuckerIOSTests"
        ),
    ]
)
