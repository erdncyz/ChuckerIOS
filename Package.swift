// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChuckerIOS",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ChuckerIOS",
            targets: ["ChuckerIOS"]
        ),
        .executable(
            name: "iOSApp",
            targets: ["iOSApp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
    ],
    targets: [
        .target(
            name: "ChuckerIOS",
            dependencies: ["Alamofire"],
            path: "Sources/ChuckerIOS"
        ),
        .executableTarget(
            name: "iOSApp",
            dependencies: ["ChuckerIOS"],
            path: "iOSApp"
        ),
    ]
)
