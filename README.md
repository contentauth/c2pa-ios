# C2PA iOS

[![Tests](https://github.com/contentauth/c2pa-ios/actions/workflows/test.yml/badge.svg)](https://github.com/contentauth/c2pa-ios/actions/workflows/test.yml)

This project provides iOS bindings to the [C2PA](https://c2pa.org/) (Content Authenticity Initiative) libraries. It wraps the C2PA Rust implementation ([c2pa-rs](https://github.com/contentauth/c2pa-rs)) using its C API bindings.

## Overview

C2PA iOS offers:

- iOS/macOS support via Swift Package/XCFramework
- Native Swift APIs for reading, verifying, and signing content with C2PA manifests
- Stream-based APIs for flexible data handling
- Builder APIs for creating custom manifests
- Comprehensive test suite with example application
- Hardware-backed signing with Secure Enclave (iOS devices)

## Repository Structure

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

## Quick Start

### Building the Library

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

### Running Applications

```bash
# Run the test app in iOS Simulator
make run-test-app

# Run the example app in iOS Simulator
make run-example-app

# Build entire workspace
make workspace-build
```

### Working with the Signing Server

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

### Swift Package Manager

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

### Local Development

For local development without using a released version:

1. Clone the repository
2. Open `C2PA.xcworkspace` in Xcode
3. Build using the workspace schemes or use the Makefile commands

## Usage

### Basic File Operations

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

### Stream-Based APIs

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

## Building from Source

1. Clone this repository:

   ```bash
   git clone https://github.com/contentauth/c2pa-ios.git
   cd c2pa-ios
   ```

2. Build the iOS framework:

   ```bash
   # Build library framework
   make library

   # Or build entire workspace
   make workspace-build
   ```

3. Run tests:

   ```bash
   # Run all tests
   make test

   # Run with coverage
   make coverage
   ```

## Makefile Targets

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

## Test App

The app includes comprehensive tests covering all major C2PA operations. Run the app and tap "Run All Tests" to see the library in action.

- **C2PA Library Version** - Display current library version
- **Error Handling** - Proper error handling for invalid files
- **Reading C2PA Data** - Extract manifest data from signed images
- **Stream APIs** - Demonstrate flexible stream-based operations
- **Builder APIs** - Sign images with custom manifest data
- **No-Embed Manifests** - Create cloud/sidecar manifests
- **Resource Management** - Add and extract resources (thumbnails, etc.)
- **Ingredient Support** - Handle ingredient relationships
- **Archive Operations** - Work with C2PA archives
- **Custom Signers** - Implement callback-based signing
- **Hardware Signing** - Use Secure Enclave for signing (iOS devices)

## Test Signing Server

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

This project is licensed under the Apache License, Version 2.0 and MIT - see the LICENSE-APACHE and LICENSE-MIT files for details.
