# Contributing to the project 

The information in this page is primarily for those who wish to contribute to the c2pa-ios project itself, rather than those who simply wish to use it in an application.  For general contribution guidelines, see [CONTRIBUTING.md](../CONTRIBUTING.md).

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

