// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "aura-sound",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AuraSound",
            targets: ["AuraSound"]
        ),
        .executable(
            name: "aura-sound",
            targets: ["AuraSoundCLI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AuraSound",
            dependencies: [],
            path: "Sources/AuraSound"
        ),
        .executableTarget(
            name: "AuraSoundCLI",
            dependencies: ["AuraSound"],
            path: "Sources/AuraSoundCLI"
        ),
        .testTarget(
            name: "AuraSoundTests",
            dependencies: ["AuraSound"],
            path: "Tests/AuraSoundTests"
        )
    ]
)
