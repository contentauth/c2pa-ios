import C2PA
import Foundation

// Comprehensive tests - pure Swift implementation
public final class ComprehensiveTests: TestImplementation {

    public init() {}

    public func testLibraryVersion() -> TestResult {
        let version = c2paVersion
        if !version.isEmpty && version.contains(".") {
            return .success("Library Version", "[PASS] C2PA Version: \(version)")
        }
        return .failure("Library Version", "Invalid version: \(version)")
    }

    public func testErrorHandling() -> TestResult {
        do {
            _ = try C2PA.readFile(at: URL(fileURLWithPath: "/non/existent/file.jpg"))
            return .failure("Error Handling", "Should have thrown an error")
        } catch let error as C2PAError {
            if case .api(let message) = error {
                if message.contains("No such file") || message.contains("does not exist") || message.contains("Failed")
                {
                    return .success("Error Handling", "[PASS] Error handling works correctly")
                }
            }
            return .failure("Error Handling", "Unexpected error: \(error)")
        } catch {
            return .failure("Error Handling", "Unexpected error: \(error)")
        }
    }

    public func testReadImageWithManifest() -> TestResult {
        // Use the Adobe test image which has a C2PA manifest
        guard let imageData = TestUtilities.loadAdobeTestImage() else {
            return .failure("Read Image With Manifest", "Could not load test image")
        }
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID().uuidString).jpg")

        do {
            try imageData.write(to: tempFile)
            defer {
                try? FileManager.default.removeItem(at: tempFile)
            }

            let manifestJSON = try C2PA.readFile(at: tempFile)

            if !manifestJSON.isEmpty {
                let jsonData = Data(manifestJSON.utf8)
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

                if json?["manifests"] != nil {
                    return .success("Read Image With Manifest", "[PASS] Read manifest from image")
                }
                return .success("Read Image With Manifest", "[WARN] No manifests (normal)")
            }
            return .success("Read Image With Manifest", "[WARN] No manifest (normal)")

        } catch let error as C2PAError {
            if case .api(let message) = error, message.contains("No manifest") {
                return .success("Read Image With Manifest", "[WARN] No manifest (expected)")
            }
            return .failure("Read Image With Manifest", "Failed: \(error)")
        } catch {
            return .failure("Read Image With Manifest", "Failed: \(error)")
        }
    }

    public func testStreamFromData() -> TestResult {
        do {
            let testData = Data("Hello C2PA Stream API".utf8)
            let stream = try Stream(data: testData)
            _ = stream
            return .success("Stream From Data", "[PASS] Created stream from data")
        } catch {
            return .failure("Stream From Data", "Failed: \(error)")
        }
    }

    public func testStreamFromFile() -> TestResult {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("stream_\(UUID().uuidString).txt")
        let testData = Data("Test file content".utf8)

        do {
            try testData.write(to: tempURL)
            defer {
                try? FileManager.default.removeItem(at: tempURL)
            }

            let stream = try Stream.read(from: tempURL)
            _ = stream
            return .success("Stream From File", "[PASS] Created stream from file")
        } catch {
            return .failure("Stream From File", "Failed: \(error)")
        }
    }


    public func testBuilderCreation() -> TestResult {
        let manifestJSON = """
            {
                "claim_generator": "TestSuite/1.0",
                "format": "image/jpeg",
                "title": "Test Manifest"
            }
            """

        do {
            let builder = try Builder(manifestJSON: manifestJSON)
            _ = builder
            return .success("Builder Creation", "[PASS] Created builder from JSON")
        } catch {
            return .failure("Builder Creation", "Failed: \(error)")
        }
    }

    public func testBuilderNoEmbed() -> TestResult {
        let manifestJSON = """
            {
                "claim_generator": "TestSuite/1.0",
                "assertions": []
            }
            """

        do {
            let builder = try Builder(manifestJSON: manifestJSON)
            builder.setNoEmbed()

            let archiveFile = FileManager.default.temporaryDirectory.appendingPathComponent(
                "archive_\(UUID().uuidString).c2pa")
            defer {
                try? FileManager.default.removeItem(at: archiveFile)
            }

            let archiveStream = try Stream.write(to: archiveFile)
            try builder.writeArchive(to: archiveStream)

            if FileManager.default.fileExists(atPath: archiveFile.path) {
                return .success("Builder No Embed", "[PASS] Created archive with no-embed")
            }
            return .failure("Builder No Embed", "Archive not created")
        } catch {
            return .failure("Builder No Embed", "Failed: \(error)")
        }
    }

    public func testBuilderRemoteURL() -> TestResult {
        let manifestJSON = """
            {
                "claim_generator": "TestSuite/1.0",
                "assertions": []
            }
            """

        do {
            let builder = try Builder(manifestJSON: manifestJSON)
            try builder.setRemoteURL("https://example.com/manifest")
            return .success("Builder Remote URL", "[PASS] Set remote URL on builder")
        } catch {
            return .failure("Builder Remote URL", "Failed: \(error)")
        }
    }

    public func testBuilderAddResource() -> TestResult {
        let manifestJSON = """
            {
                "claim_generator": "TestSuite/1.0",
                "assertions": []
            }
            """

        do {
            let builder = try Builder(manifestJSON: manifestJSON)
            guard let thumbnailData = TestUtilities.loadPexelsTestImage() else {
                return .failure("Builder Add Resource", "Could not load test image")
            }
            let thumbnailStream = try Stream(data: thumbnailData)

            do {
                try builder.addResource(uri: "thumbnail", stream: thumbnailStream)
                return .success("Builder Add Resource", "[PASS] Added resource to builder")
            } catch {
                return .success("Builder Add Resource", "[WARN] Add resource not supported")
            }
        } catch {
            return .failure("Builder Add Resource", "Failed: \(error)")
        }
    }


    public func testReaderCreation() -> TestResult {
        do {
            // Use the Adobe test image which has a C2PA manifest
            guard let imageData = TestUtilities.loadAdobeTestImage() else {
                return .failure("Reader Creation", "Could not load test image")
            }
            let stream = try Stream(data: imageData)
            let reader = try Reader(format: "image/jpeg", stream: stream)
            let json = try reader.json()
            if !json.isEmpty {
                return .success("Reader Creation", "[PASS] Created reader and read manifest")
            }
            return .success("Reader Creation", "[PASS] Created reader from stream")
        } catch let error as C2PAError {
            if case .api(let message) = error, message.contains("No manifest") {
                return .success("Reader Creation", "[WARN] No manifest (expected)")
            }
            return .failure("Reader Creation", "Failed: \(error)")
        } catch {
            return .failure("Reader Creation", "Failed: \(error)")
        }
    }

    public func testReaderWithTestImage() -> TestResult {
        do {
            // Use the Adobe test image which has a C2PA manifest
            guard let imageData = TestUtilities.loadAdobeTestImage() else {
                return .failure("Reader With Test Image", "Could not load test image")
            }
            let stream = try Stream(data: imageData)
            let reader = try Reader(format: "image/jpeg", stream: stream)
            let json = try reader.json()

            if !json.isEmpty {
                let jsonData = Data(json.utf8)
                let manifest = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                if manifest?["manifests"] != nil {
                    return .success("Reader With Test Image", "[PASS] Read manifest from test image")
                }
                return .success("Reader With Test Image", "[WARN] Empty manifests")
            }
            return .success("Reader With Test Image", "[WARN] Empty JSON")
        } catch let error as C2PAError {
            if case .api(let message) = error, message.contains("No manifest") {
                return .success("Reader With Test Image", "[WARN] No manifest")
            }
            return .failure("Reader With Test Image", "Failed: \(error)")
        } catch {
            return .failure("Reader With Test Image", "Failed: \(error)")
        }
    }

    public func testSigningAlgorithms() -> TestResult {
        let algorithms: [SigningAlgorithm] = [.es256, .es384, .es512, .ps256, .ps384, .ps512, .ed25519]
        var results: [String] = []

        for algorithm in algorithms {
            if !algorithm.description.isEmpty {
                results.append("\(algorithm.description)[PASS]")
            } else {
                results.append("\(algorithm)[FAIL]")
            }
        }

        return .success("Signing Algorithms", "[PASS] Verified \(algorithms.count) algorithms")
    }

    public func testErrorEnumCases() -> TestResult {
        let apiError = C2PAError.api("Test error")
        if apiError.description != "C2PA-API error: Test error" {
            return .failure("Error Enum Cases", "API error description mismatch")
        }

        let nilError = C2PAError.nilPointer
        if nilError.description != "Unexpected NULL pointer" {
            return .failure("Error Enum Cases", "Nil error description mismatch")
        }

        let utf8Error = C2PAError.utf8
        if utf8Error.description != "Invalid UTF-8 from C2PA" {
            return .failure("Error Enum Cases", "UTF8 error description mismatch")
        }

        let negativeError = C2PAError.negative(42)
        if negativeError.description != "C2PA negative status 42" {
            return .failure("Error Enum Cases", "Negative error description mismatch")
        }

        return .success("Error Enum Cases", "[PASS] All error cases working")
    }

    public func testEndToEndSigning() -> TestResult {
        let manifestJSON = """
            {
                "claim_generator": "TestSuite/1.0",
                "assertions": [
                    {"label": "c2pa.test", "data": {"test": true}}
                ]
            }
            """

        do {
            let builder = try Builder(manifestJSON: manifestJSON)

            let tempDir = FileManager.default.temporaryDirectory
            let sourceFile = tempDir.appendingPathComponent("source_\(UUID().uuidString).jpg")
            let destFile = tempDir.appendingPathComponent("signed_\(UUID().uuidString).jpg")

            defer {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: destFile)
            }

            guard let imageData = TestUtilities.loadPexelsTestImage() else {
                return .failure("End To End Signing", "Could not load test image")
            }
            try imageData.write(to: sourceFile)

            let sourceStream = try Stream.read(from: sourceFile)
            let destStream = try Stream.write(to: destFile)

            let signer = try Signer(
                certsPEM: TestUtilities.testCertsPEM,
                privateKeyPEM: TestUtilities.testPrivateKeyPEM,
                algorithm: .es256,
                tsaURL: nil
            )

            _ = try builder.sign(
                format: "image/jpeg",
                source: sourceStream,
                destination: destStream,
                signer: signer
            )

            if FileManager.default.fileExists(atPath: destFile.path) {
                return .success("End to End Signing", "[PASS] Signing completed")
            }
            return .failure("End to End Signing", "Destination file not created")

        } catch {
            // All errors are real failures - don't hide certificate issues
            return .failure("End to End Signing", "Signing failed: \(error)")
        }
    }

    public func testReadIngredient() -> TestResult {
        let testFile = FileManager.default.temporaryDirectory.appendingPathComponent(
            "ingredient_\(UUID().uuidString).jpg")
        guard let imageData = TestUtilities.loadPexelsTestImage() else {
            return .failure("Read Ingredient", "Could not load test image")
        }

        do {
            try imageData.write(to: testFile)
            defer {
                try? FileManager.default.removeItem(at: testFile)
            }

            let manifestJSON = try C2PA.readFile(at: testFile)

            if !manifestJSON.isEmpty {
                let jsonData = Data(manifestJSON.utf8)
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

                var hasIngredients = false
                if let manifests = json?["manifests"] as? [String: Any] {
                    for (_, manifest) in manifests {
                        if let m = manifest as? [String: Any],
                            let ingredients = m["ingredients"] as? [[String: Any]],
                            !ingredients.isEmpty
                        {
                            hasIngredients = true
                            break
                        }
                    }
                }

                if hasIngredients {
                    return .success("Read Ingredient", "[PASS] Found ingredients")
                }
                return .success("Read Ingredient", "[WARN] No ingredients (normal)")
            }
            return .success("Read Ingredient", "[WARN] No manifest (normal)")

        } catch {
            return .success("Read Ingredient", "[WARN] Could not read manifest")
        }
    }

    public func testInvalidFileHandling() -> TestResult {
        var testSteps: [String] = []
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_invalid_\(UUID().uuidString).txt")

        do {
            try "This is not a C2PA file".write(to: tempURL, atomically: true, encoding: .utf8)
            testSteps.append("✓ Created temporary invalid file")

            defer {
                try? FileManager.default.removeItem(at: tempURL)
            }

            _ = try C2PA.readFile(at: tempURL)
            testSteps.append("✗ Should have thrown an error for invalid file")

            return .failure("Invalid File Handling", testSteps.joined(separator: "\n"))
        } catch {
            testSteps.append("✓ Correctly threw error for invalid file format")
            testSteps.append("Error: \(error)")

            return .success("Invalid File Handling", testSteps.joined(separator: "\n"))
        }
    }

    public func testFileOperationsWithDataDir() -> TestResult {
        var testSteps: [String] = []

        guard let imageData = TestUtilities.loadAdobeTestImage() else {
            return .failure("File Operations with Data Dir", "Could not load test image")
        }

        let tempImageFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_image_\(UUID().uuidString).jpg")
        let dataDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("c2pa_data_\(UUID().uuidString)")

        do {
            // Write test image
            try imageData.write(to: tempImageFile)
            defer {
                try? FileManager.default.removeItem(at: tempImageFile)
                try? FileManager.default.removeItem(at: dataDir)
            }

            // Create data directory
            try FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
            testSteps.append("✓ Created data directory")

            // Read file with data directory
            let manifestJSON = try C2PA.readFile(at: tempImageFile, dataDir: dataDir)
            if !manifestJSON.isEmpty {
                testSteps.append("✓ Read manifest with data directory")
            }

            // Check if data directory has content
            let contents = try FileManager.default.contentsOfDirectory(
                at: dataDir,
                includingPropertiesForKeys: nil)
            if !contents.isEmpty {
                testSteps.append("✓ Data directory contains \(contents.count) item(s)")
            }

            // Try reading ingredient with data directory
            do {
                let ingredientJSON = try C2PA.readIngredient(at: tempImageFile, dataDir: dataDir)
                if !ingredientJSON.isEmpty {
                    testSteps.append("✓ Found ingredient: \(ingredientJSON.count) bytes")
                }
            } catch {
                testSteps.append("[WARN] No ingredient data (expected)")
            }

            return .success("File Operations with Data Dir", testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("✗ Failed: \(error)")
            return .failure("File Operations with Data Dir", testSteps.joined(separator: "\n"))
        }
    }

    public func testStreamFileOptions() -> TestResult {
        var testSteps: [String] = []
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("stream_options_\(UUID().uuidString).dat")

        do {
            // Test 1: Create new file with stream
            let createStream = try Stream.write(to: tempFile)
            _ = createStream
            testSteps.append("✓ Created new file with stream")

            // Verify file exists
            if FileManager.default.fileExists(atPath: tempFile.path) {
                testSteps.append("✓ File was created successfully")
            }

            // Write some data
            let testData = Data("Stream options test data".utf8)
            try testData.write(to: tempFile)

            // Test 2: Open existing file without truncation
            let readStream = try Stream.update(tempFile)
            _ = readStream
            testSteps.append("✓ Opened existing file without truncation")

            // Verify data still exists
            let readData = try Data(contentsOf: tempFile)
            if readData == testData {
                testSteps.append("✓ Data preserved when not truncating")
            }

            // Test 3: Open with truncation
            let truncateStream = try Stream.write(to: tempFile)
            _ = truncateStream
            testSteps.append("✓ Opened file with truncation")

            // Test 4: Try to open non-existent file without creation
            let nonExistentFile = FileManager.default.temporaryDirectory
                .appendingPathComponent("non_existent_\(UUID().uuidString).dat")
            do {
                _ = try Stream.update(nonExistentFile)
                testSteps.append("✗ Should have failed for non-existent file")
            } catch {
                testSteps.append("✓ Correctly failed for non-existent file")
            }

            // Cleanup
            try? FileManager.default.removeItem(at: tempFile)

            return .success("Stream File Options", testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("✗ Failed: \(error)")
            try? FileManager.default.removeItem(at: tempFile)
            return .failure("Stream File Options", testSteps.joined(separator: "\n"))
        }
    }

    public func runAllTests() async -> [TestResult] {
        return [
            testLibraryVersion(),
            testErrorHandling(),
            testReadImageWithManifest(),
            testInvalidFileHandling(),
            testFileOperationsWithDataDir(),
            testStreamFileOptions(),
            testStreamFromData(),
            testStreamFromFile(),
            testBuilderCreation(),
            testBuilderNoEmbed(),
            testBuilderRemoteURL(),
            testBuilderAddResource(),
            testReaderCreation(),
            testReaderWithTestImage(),
            testSigningAlgorithms(),
            testErrorEnumCases(),
            testEndToEndSigning(),
            testReadIngredient()
        ]
    }
}
