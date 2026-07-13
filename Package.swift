// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PopPangListKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PopPangListKit",
            targets: ["PopPangListKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ra1028/DifferenceKit.git",
            .upToNextMajor(from: "1.3.0")
        ),
    ],
    targets: [
        .target(
            name: "PopPangListKit",
            dependencies: [
                .product(name: "DifferenceKit", package: "DifferenceKit"),
            ]
        ),
        .testTarget(
            name: "PopPangListKitTests",
            dependencies: ["PopPangListKit"]
        ),
    ]
)
