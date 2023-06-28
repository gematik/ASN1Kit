// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ASN1Kit",
    platforms: [
        // specify each minimum deployment requirement,
        //otherwise the platform default minimum is used.
       .macOS(.v10_12),
       .iOS(.v9),
       .tvOS(.v9),
       .watchOS(.v2)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ASN1Kit",
            targets: ["ASN1Kit"]),
        .executable(
            name: "CLI",
            targets: ["CLI", "ASN1Kit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "http://github.com/Quick/Nimble", from: "9.2.0"),
        .package(url: "https://github.com/SwiftCommon/DataKit.git", from: "1.1.0"),
        .package(url: "http://github.com/Carthage/Commandant", from: "0.17.0"),
        .package(name: "GemCommonsKit", url: "https://github.com/gematik/ref-GemCommonsKit", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ASN1Kit",
            dependencies: ["DataKit", "GemCommonsKit"]),
        .executableTarget(
            name: "CLI",
            dependencies: ["ASN1Kit", "Commandant"]),
        .testTarget(
            name: "ASN1KitTests",
            dependencies: ["ASN1Kit", "Nimble"]),
    ],
    swiftLanguageVersions: [.v5]
)
