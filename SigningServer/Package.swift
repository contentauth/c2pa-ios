// swift-tools-version:5.9

// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import PackageDescription

let package = Package(
    name: "SigningServer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SigningServer", targets: ["SigningServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-asn1.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "SigningServer",
            dependencies: [
                .target(name: "App")
            ],
            path: "Sources/Run"
        ),
        .systemLibrary(
            name: "C2PAC",
            path: "Sources/C2PAC"
        ),
        .target(
            name: "C2PA",
            dependencies: [
                "C2PAC",
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "_CryptoExtras", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/C2PA"
        ),
        .target(
            name: "App",
            dependencies: [
                "C2PA",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            resources: [
                .copy("Resources")
            ],
            linkerSettings: [
                .unsafeFlags(["-Llibs", "-lc2pa_c"])
            ]
        )
    ]
)
