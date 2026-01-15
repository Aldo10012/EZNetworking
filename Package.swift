// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EZNetworking",
    platforms: [
        .iOS(.v15), // Set the minimum iOS version here
        .macOS(.v10_15),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EZNetworking",
            targets: ["EZNetworking"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EZNetworking"),
        .testTarget(
            name: "EZNetworkingTests",
            dependencies: ["EZNetworking"]),
    ]
)
