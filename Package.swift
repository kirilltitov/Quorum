// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Quorum",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "Quorum", targets: ["Quorum"]),
        .library(name: "Generated", targets: ["Generated"]),
    ],
    dependencies: [
        .package(url: "git@github.com:1711-games/LGNC-Swift.git", branch: "upgrade-5.7"),
        .package(url: "git@github.com:kirilltitov/FDBSwift.git", branch: "upgrade-5.7"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "1.0.0-alpha.10"),
        .package(url: "https://github.com/1711-Games/LGN-Log.git", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/1711-games/LGN-Config", from: "0.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "Quorum",
            dependencies: [
                .target(name: "Generated"),
                .product(name: "LGNLog", package: "LGN-Log"),
                .product(name: "LGNConfig", package: "LGN-Config"),
                .product(name: "LGNC", package: "LGNC-Swift"),
                .product(name: "FDBEntity", package: "FDBSwift"),
                .product(name: "Lifecycle", package: "swift-service-lifecycle"),
                .product(name: "LifecycleNIOCompat", package: "swift-service-lifecycle"),
            ]
        ),
        .target(
            name: "Generated",
            dependencies: [
                .product(name: "LGNC", package: "LGNC-Swift"),
                .product(name: "Entita", package: "LGNC-Swift"),
            ]
        ),
        .testTarget(name: "QuorumTests", dependencies: ["Quorum"]),
    ]
)
