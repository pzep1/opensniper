// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OpenSniper",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "OpenSniperCore", targets: ["OpenSniperCore"]),
        .executable(name: "OpenSniper", targets: ["OpenSniper"])
    ],
    targets: [
        .target(name: "OpenSniperCore"),
        .executableTarget(
            name: "OpenSniper",
            dependencies: ["OpenSniperCore"]
        ),
        .testTarget(
            name: "OpenSniperCoreTests",
            dependencies: ["OpenSniperCore"]
        )
    ]
)
