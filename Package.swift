// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "SimplenoteInterlinks",
    platforms: [.macOS(.v10_13),
                .iOS(.v11)],
    products: [
        .library(
            name: "SimplenoteInterlinks",
            targets: ["SimplenoteInterlinks"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SimplenoteInterlinks",
                path: "Sources/SimplenoteInterlinks"),
        .testTarget(name: "SimplenoteInterlinksTests",
                    dependencies: ["SimplenoteInterlinks"])
    ],
    swiftLanguageVersions: [.v5]
)
