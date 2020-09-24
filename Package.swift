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
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(
            name: "SimplenoteFoundation",
            url: "https://github.com/Automattic/SimplenoteFoundation-Swift",
            from: "1.0.0"
//            .branch("issue/range-extensions")
        )
    ],
    targets: [
        .target(name: "SimplenoteInterlinks",
                dependencies: ["SimplenoteFoundation"],
                path: "Sources/SimplenoteInterlinks"),
        .testTarget(name: "SimplenoteInterlinksTests",
                    dependencies: ["SimplenoteInterlinks"])
    ],
    swiftLanguageVersions: [.v5]
)
