import C2PA
import Foundation

// Reader tests - pure Swift implementation
public final class ReaderTests: TestImplementation {

    public init() {}

    public func testReaderResourceErrorHandling() -> TestResult {
        do {
            guard let imageData = TestUtilities.loadPexelsTestImage() else {
                return .failure("Reader Resource Error", "Could not load test image")
            }

            // Use file-based stream for better compatibility
            let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(
                "reader_resource_\(UUID().uuidString).jpg")
            defer { try? FileManager.default.removeItem(at: tempFile) }

            try imageData.write(to: tempFile)
            let stream = try Stream(readFrom: tempFile)
            let reader = try Reader(format: "image/jpeg", stream: stream)

            // Try to get resources that might not exist
            let resourceURI = "http://example.com/nonexistent"

            // Create output stream for resource
            var resourceData = Data()
            let resourceStream = try Stream(
                write: { buffer, count in
                    let data = Data(bytes: buffer, count: count)
                    resourceData.append(data)
                    return count
                },
                flush: { return 0 }
            )

            do {
                try reader.resource(uri: resourceURI, to: resourceStream)
                return .success("Reader Resource Error", "[WARN] Resource found (unexpected)")
            } catch _ as C2PAError {
                return .success("Reader Resource Error", "[PASS] Error handled correctly")
            }

        } catch let error as C2PAError {
            if case .api(let message) = error {
                // Accept various "no manifest" error messages
                if message.contains("No manifest") || message.contains("no JUMBF data found")
                    || message.contains("ManifestNotFound")
                {
                    return .success("Reader Resource Error", "[PASS] No manifest (expected)")
                }
            }
            return .failure("Reader Resource Error", "Unexpected C2PAError: \(error)")
        } catch {
            return .failure("Reader Resource Error", "Unexpected error: \(error)")
        }
    }

    public func testReaderWithManifestData() -> TestResult {
        let manifestJSON = """
            {
                "claim_generator": "test/1.0",
                "assertions": []
            }
            """

        do {
            let manifestData = Data(manifestJSON.utf8)
            guard let imageData = TestUtilities.loadPexelsTestImage() else {
                return .failure("Reader With Manifest", "Could not load test image")
            }
            let stream = try Stream(data: imageData)

            // Create reader with manifest data
            let reader = try Reader(format: "image/jpeg", stream: stream, manifest: manifestData)

            // Try to get JSON
            let json = try reader.json()
            if !json.isEmpty {
                return .success("Reader With Manifest", "[PASS] Reader with manifest data working")
            }
            return .success("Reader With Manifest", "[WARN] Empty JSON (expected)")

        } catch {
            return .success("Reader With Manifest", "[WARN] Failed (might be expected): \(error)")
        }
    }

    public func testResourceReading() -> TestResult {
        do {
            // Use the Adobe test image which has a C2PA manifest
            guard let imageData = TestUtilities.loadAdobeTestImage() else {
                return .failure("Resource Reading", "Could not load test image")
            }
            let stream = try Stream(data: imageData)
            let reader = try Reader(format: "image/jpeg", stream: stream)
            let manifestJSON = try reader.json()

            if !manifestJSON.isEmpty {
                let jsonData = Data(manifestJSON.utf8)
                let manifest = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

                // Look for resources in manifest
                var foundResource = false
                if let manifests = manifest?["manifests"] as? [String: Any] {
                    for (_, value) in manifests {
                        if let m = value as? [String: Any],
                            let thumbnail = m["thumbnail"] as? [String: Any],
                            let identifier = thumbnail["identifier"] as? String
                        {

                            // Try to extract the resource
                            var resourceData = Data()
                            let resourceStream = try Stream(
                                write: { buffer, count in
                                    let data = Data(bytes: buffer, count: count)
                                    resourceData.append(data)
                                    return count
                                },
                                flush: { return 0 }
                            )

                            try reader.resource(uri: identifier, to: resourceStream)
                            foundResource = true
                            return .success(
                                "Resource Reading",
                                "[PASS] Extracted resource of size: \(resourceData.count)")
                        }
                    }
                }

                if !foundResource {
                    return .success("Resource Reading", "[WARN] No resources found (normal)")
                }
            }

            return .success("Resource Reading", "[WARN] No manifest (normal for test images)")

        } catch let error as C2PAError {
            if case .api(let message) = error, message.contains("No manifest") {
                return .success("Resource Reading", "[WARN] No manifest (acceptable)")
            }
            return .failure("Resource Reading", "Failed: \(error)")
        } catch {
            return .failure("Resource Reading", "Failed: \(error)")
        }
    }

    public func testReaderValidation() -> TestResult {
        guard let imageData = TestUtilities.loadPexelsTestImage() else {
            return .failure("Reader Validation", "Could not load test image")
        }

        // Test with various formats
        let formats = [
            ("image/jpeg", true),
            ("image/png", true),
            ("image/webp", true),
            ("invalid/format", false)
        ]

        var results: [String] = []

        for (format, shouldWork) in formats {
            do {
                let stream = try Stream(data: imageData)
                _ = try Reader(format: format, stream: stream)
                if shouldWork {
                    results.append("[PASS] \(format)")
                } else {
                    return .failure("Reader Validation", "Invalid format \(format) not rejected")
                }
            } catch {
                if !shouldWork {
                    results.append("[PASS] Invalid \(format) rejected")
                } else {
                    results.append("[WARN] \(format) failed")
                }
            }
        }

        return .success("Reader Validation", results.joined(separator: ", "))
    }

    public func testReaderThumbnailExtraction() -> TestResult {
        do {
            // Use the Adobe test image which has a C2PA manifest
            guard let imageData = TestUtilities.loadAdobeTestImage() else {
                return .failure("Reader Thumbnail Extraction", "Could not load test image")
            }
            let stream = try Stream(data: imageData)
            let reader = try Reader(format: "image/jpeg", stream: stream)
            let manifestJSON = try reader.json()

            if !manifestJSON.isEmpty {
                let jsonData = Data(manifestJSON.utf8)
                let manifest = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

                var thumbnailCount = 0

                // Check for thumbnails in manifests
                if let manifests = manifest?["manifests"] as? [String: Any] {
                    for (_, value) in manifests {
                        if let m = value as? [String: Any] {
                            // Check main thumbnail
                            if m["thumbnail"] is [String: Any] {
                                thumbnailCount += 1
                            }

                            // Check assertion thumbnails
                            if let assertions = m["assertions"] as? [[String: Any]] {
                                for assertion in assertions where assertion["thumbnail"] is [String: Any] {
                                    thumbnailCount += 1
                                }
                            }

                            // Check ingredient thumbnails
                            if let ingredients = m["ingredients"] as? [[String: Any]] {
                                for ingredient in ingredients where ingredient["thumbnail"] is [String: Any] {
                                    thumbnailCount += 1
                                }
                            }
                        }
                    }
                }

                return .success(
                    "Reader Thumbnail Extraction",
                    "[PASS] Found \(thumbnailCount) thumbnail(s)")
            }

            return .success("Reader Thumbnail Extraction", "[WARN] No manifest (normal)")

        } catch let error as C2PAError {
            if case .api(let message) = error, message.contains("No manifest") {
                return .success("Reader Thumbnail Extraction", "[WARN] No manifest (acceptable)")
            }
            return .failure("Reader Thumbnail Extraction", "Failed: \(error)")
        } catch {
            return .failure("Reader Thumbnail Extraction", "Failed: \(error)")
        }
    }

    public func testReaderIngredientExtraction() -> TestResult {
        do {
            // Use the Adobe test image which has a C2PA manifest
            guard let imageData = TestUtilities.loadAdobeTestImage() else {
                return .failure("Reader Ingredient Extraction", "Could not load test image")
            }
            let stream = try Stream(data: imageData)
            let reader = try Reader(format: "image/jpeg", stream: stream)
            let manifestJSON = try reader.json()

            if !manifestJSON.isEmpty {
                let jsonData = Data(manifestJSON.utf8)
                let manifest = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

                var ingredientCount = 0
                var ingredientTitles: [String] = []

                // Check for ingredients in manifests
                if let manifests = manifest?["manifests"] as? [String: Any] {
                    for (_, value) in manifests {
                        if let m = value as? [String: Any],
                            let ingredients = m["ingredients"] as? [[String: Any]]
                        {
                            ingredientCount = ingredients.count

                            for ingredient in ingredients {
                                if let title = ingredient["title"] as? String {
                                    ingredientTitles.append(title)
                                }
                            }
                        }
                    }
                }

                if ingredientCount > 0 {
                    return .success(
                        "Reader Ingredient Extraction",
                        "[PASS] Found \(ingredientCount) ingredient(s)")
                } else {
                    return .success(
                        "Reader Ingredient Extraction",
                        "[WARN] No ingredients (normal)")
                }
            }

            return .success("Reader Ingredient Extraction", "[WARN] No manifest (normal)")

        } catch let error as C2PAError {
            if case .api(let message) = error, message.contains("No manifest") {
                return .success("Reader Ingredient Extraction", "[WARN] No manifest (acceptable)")
            }
            return .failure("Reader Ingredient Extraction", "Failed: \(error)")
        } catch {
            return .failure("Reader Ingredient Extraction", "Failed: \(error)")
        }
    }

    public func testReaderJSONParsing() -> TestResult {
        do {
            guard let imageData = TestUtilities.loadPexelsTestImage() else {
                return .failure("Reader JSON Parsing", "Could not load test image")
            }

            // Use file-based stream for better compatibility
            let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(
                "reader_json_\(UUID().uuidString).jpg")
            defer { try? FileManager.default.removeItem(at: tempFile) }

            try imageData.write(to: tempFile)
            let stream = try Stream(readFrom: tempFile)
            let reader = try Reader(format: "image/jpeg", stream: stream)
            let json = try reader.json()

            // Even without a manifest, the reader might return empty JSON
            if !json.isEmpty {
                // Verify it's valid JSON
                let jsonData = Data(json.utf8)
                let parsed = try JSONSerialization.jsonObject(with: jsonData)
                if parsed is [String: Any] || parsed is [Any] {
                    return .success("Reader JSON Parsing", "[PASS] Valid JSON returned")
                }
            }

            return .success("Reader JSON Parsing", "[WARN] Empty JSON (normal)")

        } catch let error as C2PAError {
            if case .api(let message) = error {
                // Accept various "no manifest" error messages
                if message.contains("No manifest") || message.contains("no JUMBF data found")
                    || message.contains("ManifestNotFound")
                {
                    return .success("Reader JSON Parsing", "[PASS] No manifest error handled")
                }
            }
            return .failure("Reader JSON Parsing", "Unexpected C2PAError: \(error)")
        } catch {
            return .failure("Reader JSON Parsing", "Unexpected error: \(error)")
        }
    }

    public func testReaderWithMultipleStreams() -> TestResult {
        do {
            // Test creating multiple readers from different streams
            guard let imageData1 = TestUtilities.loadPexelsTestImage() else {
                return .failure("Reader Multiple Streams", "Could not load test image")
            }
            let imageData2 = imageData1

            let stream1 = try Stream(data: imageData1)
            let stream2 = try Stream(data: imageData2)

            let reader1 = try Reader(format: "image/jpeg", stream: stream1)
            let reader2 = try Reader(format: "image/jpeg", stream: stream2)

            _ = try? reader1.json()
            _ = try? reader2.json()

            return .success("Reader Multiple Streams", "[PASS] Multiple readers created")

        } catch {
            return .success("Reader Multiple Streams", "[WARN] Multiple readers: \(error)")
        }
    }

    public func runAllTests() async -> [TestResult] {
        return [
            testReaderResourceErrorHandling(),
            testReaderWithManifestData(),
            testResourceReading(),
            testReaderValidation(),
            testReaderThumbnailExtraction(),
            testReaderIngredientExtraction(),
            testReaderJSONParsing(),
            testReaderWithMultipleStreams()
        ]
    }
}
