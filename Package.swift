// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EdgeTTS",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "EdgeTTS",
            targets: ["EdgeTTS"]
        ),
    ],
    targets: [
        .target(
            name: "EdgeTTS"
        ),
        .testTarget(
            name: "EdgeTTSTests",
            dependencies: ["EdgeTTS"]
        ),
    ]
)
