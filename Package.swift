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
            name: "Web3swift",
            url: "https://github.com/skywinder/web3swift.git",
            .branch("develop")
        ),
        .package(
            name: "Alamofire",
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.4.3"
        )
    ],
    targets: [
        .target(
            name: "ZKSync",
            dependencies: [
                "ZKSyncCrypto",
                .product(name: "web3swift", package: "Web3swift"),
                "Alamofire"
            ],
            path: "Sources/ZKSync"),
        .binaryTarget(
            name: "ZKSyncCrypto",
            path: "Dependencies/ZKSyncCrypto.xcframework"),
    ]
)
