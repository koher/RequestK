// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "RequestK",
    dependencies: [
        .Package(url: "https://github.com/koher/PromiseK.git", majorVersion: 2),
        .Package(url: "https://github.com/koher/ResultK.git", majorVersion: 0),
    ]
)
