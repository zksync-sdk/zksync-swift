// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZKSync",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZKSync",
            targets: [
                "ZKSync"
            ]),
    ],
    dependencies: [
        .package(
            name: "Alamofire",
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.4.3"
        ),
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.0"
        ),
        .package(
            name: "CryptoSwift",
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.4.1"
        ),
        .package(
            name: "PromiseKit",
            url: "https://github.com/mxcl/PromiseKit.git",
            from: "6.16.0"
        ),
        .package(
            name: "secp256k1",
            url: "https://github.com/Boilertalk/secp256k1.swift",
            from: "0.1.0"
        )
    ],
    targets: [
        .target(
            name: "ZKSync",
            dependencies: [
                "ZKSyncCrypto",
                "Alamofire",
                "BigInt",
                "CryptoSwift",
                "PromiseKit",
                "secp256k1"
            ],
            path: "Sources/ZKSync"),
        .binaryTarget(
            name: "ZKSyncCrypto",
            path: "Dependencies/ZKSyncCrypto.xcframework"),
    ]
)
