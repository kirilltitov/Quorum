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
        .package(url: "git@github.com:kirilltitov/Entita2FDB.git", .branch("master")),
        .package(url: "https://github.com/swift-server/swift-backtrace.git", from: "1.1.1"),
    ],
    targets: [
        .target(
            name: "Quorum",
            dependencies: [
                .target(name: "Generated"),
                .product(name: "LGNC", package: "LGNKit"),
                .product(name: "Entita2FDB", package: "Entita2FDB"),
                .product(name: "Backtrace", package: "swift-backtrace"),
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
