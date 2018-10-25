// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "RequestK",
    products: [
        .library(name: "RequestK", targets: ["RequestK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/koher/PromiseK.git", from: "3.0.0"),
        .package(url: "https://github.com/koher/ResultK.git", from: "0.2.0-alpha"),
    ],
    targets: [
        .target(name: "RequestK", dependencies: ["PromiseK", "ResultK"]),
        .testTarget(name: "RequestKTests", dependencies: ["PromiseK", "ResultK", "RequestK"]),
    ]
)
