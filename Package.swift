// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Quorum",
    products: [
        .executable(name: "Quorum", targets: ["Quorum"]),
        .library(name: "Generated", targets: ["Generated"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        //.package(url: "git@bitbucket.org:1711-games/LGNC-Swift.git", .branch("master")),
        //.package(url: "git@bitbucket.org:1711-games/Entita2FDB.git", .branch("master")),
        .package(url: "git@bitbucket.org:1711-games/LGNKit-Swift.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "Quorum", dependencies: ["Generated", "LGNC", "Entita2FDB"]),
        .target(name: "Generated", dependencies: ["LGNC"]),
        .testTarget(name: "QuorumTests", dependencies: ["Quorum"]),
    ]
)
