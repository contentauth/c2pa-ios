# C2PA iOS

[![Tests](https://github.com/contentauth/c2pa-ios/actions/workflows/test.yml/badge.svg)](https://github.com/contentauth/c2pa-ios/actions/workflows/test.yml)

This project provides iOS bindings to the [Content Authenticity Initiative SDK](https://opensource.contentauthenticity.org/docs/). It wraps [c2pa-rs Rust library](https://github.com/contentauth/c2pa-rs) using its C API bindings.

## Overview

C2PA iOS offers:

- iOS/macOS support via Swift Package/XCFramework
- Native Swift APIs for reading, verifying, and signing content with C2PA manifests
- Stream-based APIs for flexible data handling
- Builder APIs for creating custom manifests
- Comprehensive test suite with example application
- Hardware-backed signing with Secure Enclave (iOS devices)

> [!NOTE] 
> This project officially supports only iOS, even though it may run on other platforms that support Swift.

For information on contributing to the project, see [Project contributions](https://github.com/contentauth/c2pa-ios/tree/main/docs/project-contributions.md).

## Repository structure

```
c2pa-ios/
├── Library/              # Swift Package containing the C2PA library
│   ├── Sources/         # Library source code
│   │   └── C2PA/       # Main library implementation
│   ├── Frameworks/     # Pre-built XCFramework
│   │   └── C2PAC.xcframework/
│   └── Tests/          # Unit tests
│       └── C2PATests/  # Test implementations
├── TestApp/            # iOS app for running tests with UI
├── ExampleApp/         # Sample iOS app for implementation reference
├── TestShared/         # Shared test utilities and fixtures
├── SigningServer/      # Local test server for signing operations
├── C2PA.xcworkspace/   # Xcode workspace tying everything together
└── Makefile           # Build automation (wraps xcodebuild/swift commands)
```

## Requirements

### iOS

- iOS 15.0+ / macOS 11.0+
- Xcode 13.0+
- Swift 5.9+

### Development

- Xcode Command Line Tools
- Make

## Quick start

### Building the library

```bash
# Build the complete library with XCFramework
make library

# Build iOS framework (release configuration)
make ios-framework

# Run all tests
make test

# Run library tests only
make test-library

# Generate test coverage
make coverage
```

### Running applications

```bash
# Run the test app in iOS Simulator
make run-test-app

# Run the example app in iOS Simulator
make run-example-app

# Build entire workspace
make workspace-build
```

### Working with the signing server

```bash
# Start the local signing server
make signing-server-start

# Check server status
make signing-server-status

# Stop the server
make signing-server-stop

# Run tests with signing server
make tests-with-server
```

## Installation

### Swift package manager

You can add C2PA iOS as a Swift Package Manager dependency:

```swift
dependencies: [
    .package(url: "https://github.com/contentauth/c2pa-ios.git", from: "0.0.1")
]
```

In your target, add the dependency:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [.product(name: "C2PA", package: "c2pa-ios")]
    )
]
```

### Local development

For local development without using a released version:

1. Clone the repository
2. Open `C2PA.xcworkspace` in Xcode
3. Build using the workspace schemes or use the Makefile commands

## Usage

### Basic file operations

```swift
import C2PA

// Read C2PA data from a file
do {
    let manifestJSON = try C2PA.readFile(at: imageURL)
    print("C2PA manifest: \(manifestJSON)")
} catch {
    print("Error reading C2PA data: \(error)")
}

// Sign a file with C2PA data
let signerInfo = SignerInfo(
    algorithm: .es256,
    certificatePEM: certificatePEM,
    privateKeyPEM: privateKeyPEM,
    tsaURL: nil
)

let manifestJSON = """
{
    "claim_generator": "MyApp/1.0",
    "title": "Signed Image",
    "format": "image/jpeg"
}
"""

try C2PA.signFile(
    source: inputURL,
    destination: outputURL,
    manifestJSON: manifestJSON,
    signerInfo: signerInfo
)
```

### Stream-based APIs

```swift
// Create stream from data
let imageData = try Data(contentsOf: imageURL)
let stream = try Stream(data: imageData)

// Read with Reader API
let reader = try Reader(format: "image/jpeg", stream: stream)
let manifestJSON = try reader.json()

// Sign with Builder API
let builder = try Builder(manifestJSON: manifestJSON)
let signer = try Signer(info: signerInfo)

let sourceStream = try Stream(data: imageData)
let destStream = try Stream(fileURL: outputURL)

let manifestData = try builder.sign(
    format: "image/jpeg",
    source: sourceStream,
    destination: destStream,
    signer: signer
)
```

## Makefile targets

The project includes a comprehensive Makefile with various targets:

- `library` - Build the C2PA library framework
- `ios-framework` - Build iOS framework (release configuration)
- `test` - Run all tests (alias for test-library)
- `test-library` - Run library unit tests only
- `tests` - Run all tests including UI tests
- `coverage` - Generate test coverage report
- `workspace-build` - Build entire workspace
- `run-test-app` - Run test app in simulator
- `run-example-app` - Run example app in simulator
- `signing-server-start` - Start signing server
- `signing-server-stop` - Stop signing server
- `signing-server-status` - Check server status
- `tests-with-server` - Run tests with signing server
- `clean` - Clean build artifacts
- `lint` - Run SwiftLint on the codebase
- `help` - Show all available targets

## Test signing server

For testing certificate enrollment and C2PA signing, a Swift-based signing server is included:

```bash
# Start the test server
make signing-server-start
```

The server runs on `http://localhost:8080` and provides:

- **Certificate Authority**: Signs Certificate Signing Requests (CSRs) for testing
- **C2PA Signing**: Server-side C2PA manifest signing
- **Bearer Token Authentication**: For development/testing only

### Key Endpoints

- `GET /health` - Health check
- `POST /api/v1/certificates/sign` - Sign a CSR
- `POST /api/v1/c2pa/sign` - Sign image with C2PA manifest

**⚠️ Testing Only**: This server is intended for development and testing only. For production use, implement proper authentication and security measures.

## License

This project is licensed under the Apache License, Version 2.0 and MIT License. See the [LICENSE-APACHE](https://github.com/contentauth/c2pa-ios/blob/main/LICENSE-APACHE) and [LICENSE-MIT](https://github.com/contentauth/c2pa-ios/blob/main/LICENSE-MIT) files for details.
