// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bilboard",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Bilboard",
            targets: ["Bilboard"]
        ),
        .library(
            name: "BilboardMobile",
            targets: ["BilboardMobile"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/twostraws/swiftgd.git", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Bilboard",
            dependencies: [
                .product(name: "SwiftGD", package: "SwiftGD")
            ],
            resources: [
                .copy("Resources/fonts.txt")
            ]
        ),
        .target(
            name: "BilboardMobile",
            resources: [
                .copy("Resources/fonts.txt")
            ]
        ),
        .testTarget(
            name: "BilboardTests",
            dependencies: ["Bilboard"]
        )
    ]
)
