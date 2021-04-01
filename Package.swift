// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Quorum",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "Quorum", targets: ["Quorum"]),
        .library(name: "Generated", targets: ["Generated"]),
    ],
    dependencies: [
        .package(name: "LGNC-Swift", url: "git@github.com:1711-games/LGNC-Swift.git", .branch("async-await")),
        .package(url: "git@github.com:1711-Games/Entita2FDB.git", .branch("async-await")),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "1.0.0-alpha.7"),
    ],
    targets: [
        .target(
            name: "Quorum",
            dependencies: [
                .target(name: "Generated"),
                .product(name: "LGNC", package: "LGNC-Swift"),
                .product(name: "Entita2FDB", package: "Entita2FDB"),
                .product(name: "Lifecycle", package: "swift-service-lifecycle"),
                .product(name: "LifecycleNIOCompat", package: "swift-service-lifecycle"),
            ],
            swiftSettings: [.unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"])]
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
