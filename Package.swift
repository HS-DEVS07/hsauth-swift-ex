// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "HSAuth",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "HSAuth", targets: ["HSAuth"]),
    ],
    targets: [
        .target(name: "HSAuth", dependencies: []),
    ]
)
