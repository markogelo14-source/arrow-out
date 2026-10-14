// swift-tools-version:5.9
// Runs the game's rules and level generator tests without Xcode: `swift test` in this folder.
// The sources are the same files the app uses (Arrowly/Model), linked in by the script below.
import PackageDescription

let package = Package(
    name: "ArrowlyCore",
    targets: [
        .target(name: "ArrowlyCore", path: "Sources/ArrowlyCore"),
        .testTarget(name: "ArrowlyCoreTests", dependencies: ["ArrowlyCore"], path: "Tests/ArrowlyCoreTests"),
    ]
)
