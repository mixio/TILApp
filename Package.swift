// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "TILApp",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.8"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),

        // 🛠 JJTools.
        .package(url: "https://github.com/mixio/jjtools.git", from: "0.1.0"),

        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.1"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),

        .package(url: "https://github.com/vapor-community/Imperial.git", from: "0.7.1")

    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Leaf", "JJTools", "Authentication", "Imperial"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

