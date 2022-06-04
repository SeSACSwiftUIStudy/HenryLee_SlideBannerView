// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlideBannerView",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "SlideBannerView",
            targets: ["SlideBannerView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SlideBannerView",
            dependencies: [])
    ]
)
