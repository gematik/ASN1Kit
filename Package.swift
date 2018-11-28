// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ASN1Kit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ASN1Kit",
            targets: ["ASN1Kit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://build.top.local/source/git/refImpl/mobszen/iOS/GemCommonsKit.git", .branch("Development_1.x")),
        .package(url: "https://build.top.local/source/git/refImpl/mobszen/iOS/oss-mirror/Nimble.git", from: "7.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ASN1Kit",
            dependencies: ["GemCommonsKit"]),
        .testTarget(
            name: "ASN1KitTests",
            dependencies: ["ASN1Kit", "Nimble"]),
    ]
)
