// swift-tools-version:5.5

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
        .package(url: "git@github.com:1711-Games/Entita2FDB.git", from: "1.0.0-RC-3"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "1.0.0-alpha.10"),
        .package(url: "https://github.com/1711-Games/LGN-Log.git", .upToNextMinor(from: "0.2.0")),
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
                .product(name: "Entita2FDB", package: "Entita2FDB"),
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
