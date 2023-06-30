// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NuncUI",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "NuncUI", targets: ["NuncUI"])
    ],
    targets: [
        .target(name: "NuncUI")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
