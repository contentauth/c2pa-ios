// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "C2PA",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "C2PA",
            targets: ["C2PA"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-certificates.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-asn1.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .binaryTarget(
            name: "C2PAC",
            url: "https://github.com/contentauth/c2pa-ios/releases/download/v0.0.7/C2PAC.xcframework.zip",
            checksum: "d83c7022cc275fb1b4e19804761795c02035d63b6300bdd48af37ea04db6558a"
        ),
        .target(
            name: "C2PA",
            dependencies: [
                "C2PAC",
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Library/Sources"
        )
    ]
)
