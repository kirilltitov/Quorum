// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Quorum",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "Quorum", targets: ["Quorum"]),
        .library(name: "Generated", targets: ["Generated"]),
    ],
    dependencies: [
        .package(name: "LGNKit", url: "git@github.com:1711-games/LGNKit-Swift.git", .branch("master")),
        .package(url: "git@github.com:1711-Games/Entita2FDB.git", .branch("master")),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "1.0.0-alpha.4"),
    ],
    targets: [
        .target(
            name: "Quorum",
            dependencies: [
                .target(name: "Generated"),
                .product(name: "LGNC", package: "LGNKit"),
                .product(name: "Entita2FDB", package: "Entita2FDB"),
                .product(name: "Lifecycle", package: "swift-service-lifecycle"),
                .product(name: "LifecycleNIOCompat", package: "swift-service-lifecycle"),
            ]
        ),
        .target(
            name: "Generated",
            dependencies: [
                .product(name: "LGNC", package: "LGNKit"),
                .product(name: "Entita", package: "LGNKit"),
            ]
        ),
        .testTarget(name: "QuorumTests", dependencies: ["Quorum"]),
    ]
)
