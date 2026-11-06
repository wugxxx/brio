// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "Brio",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(name: "Brio"),
        .testTarget(name: "BrioTests", dependencies: ["Brio"])
    ],
    swiftLanguageModes: [.v6]
)
