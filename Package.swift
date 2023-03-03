// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureToggling",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FeatureToggling",
            targets: ["FeatureToggling"]),
    ],
    dependencies: [.package(url: "https://github.com/nasriniazi/LogManager.git", branch: "main"),.package(url: "https://github.com/nasriniazi/Theme.git", branch: "main"),.package(url: "https://github.com/nasriniazi/Coordinator.git", branch: "main")
                  ],
    targets: [
        .target(
            name: "FeatureToggling",
            dependencies: [.product(name: "LogManager", package: "LogManager"),.product(name: "Theme", package: "Theme"),.product(name: "Coordinator", package: "Coordinator")],resources: [],swiftSettings: [.define("SPM")]),
        .testTarget(
            name: "FeatureTogglingTests",
            dependencies: ["FeatureToggling"],resources: [.copy("JSON")]),
    ]
)
//
