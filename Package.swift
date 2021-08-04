// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyOverlay",
    products: [
        .library(
            name: "SwiftyOverlay",
            targets: ["SwiftyOverlay"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sources/SwiftyOverlay",
            dependencies: []),
        .testTarget(
            name: "SwiftyOverlayTests",
            dependencies: ["SwiftyOverlay"]),
    ]
)
