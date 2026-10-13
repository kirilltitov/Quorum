// swift-tools-version:6.4

import PackageDescription

let package = Package(
    name: "Quorum",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "Quorum", targets: ["Quorum"]),
        .library(name: "Generated", targets: ["Generated"]),
    ],
    dependencies: [
        .package(url: "https://github.com/1711-Games/LGNC-Swift.git", branch: "main"),
        .package(url: "https://github.com/kirilltitov/FDBSwift.git", branch: "master"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.6.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.25.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.80.0"),
        .package(url: "https://github.com/1711-Games/LGN-Log.git", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/1711-Games/LGN-Config.git", from: "0.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "Quorum",
            dependencies: [
                .target(name: "Generated"),
                .product(name: "LGNLog", package: "LGN-Log"),
                .product(name: "LGNConfig", package: "LGN-Config"),
                .product(name: "LGNC", package: "LGNC-Swift"),
                .product(name: "FDB", package: "FDBSwift"),
                .product(name: "FDBEntity", package: "FDBSwift"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "Generated",
            dependencies: [
                .product(name: "LGNC", package: "LGNC-Swift"),
                .product(name: "Entita", package: "LGNC-Swift"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "QuorumTests",
            dependencies: ["Quorum", .product(name: "FDBEntity", package: "FDBSwift")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
