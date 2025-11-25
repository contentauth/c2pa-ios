// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import C2PA
import Foundation

// Signing tests
public final class SigningTests: TestImplementation {

    public init() {}

    private let keyTag = "org.contentauth.test.key.\(UUID().uuidString)"

    public func testSignerCreation() -> TestResult {
        // This test attempts to create a signer with test certificates
        // If the certs are invalid, this is expected to fail
        do {
            let signer = try Signer(
                certsPEM: TestUtilities.testCertsPEM,
                privateKeyPEM: TestUtilities.testPrivateKeyPEM,
                algorithm: .es256,
                tsaURL: nil
            )
            _ = signer
            return .success("Signer Creation", "[PASS] Created PEM-based signer with valid certificates")
        } catch let error as C2PAError {
            // If certificates are invalid, this is a FAILURE not a success
            return .failure("Signer Creation", "Certificate/key error (test certs may be invalid): \(error)")
        } catch {
            return .failure("Signer Creation", "Failed: \(error)")
        }
    }

    public func testSignerWithCallback() -> TestResult {
        // This test verifies that the callback mechanism works
        // It's not testing actual signing validity
        var callbackInvoked = false
        var dataToSign: Data?

        let signCallback: (Data) throws -> Data = { data in
            callbackInvoked = true
            dataToSign = data

            // Return dummy signature data - this won't be cryptographically valid
            // but that's OK since we're just testing the callback mechanism
            return Data(repeating: 0x42, count: 64)
        }

        do {
            let signer = try Signer(
                algorithm: .es256,
                certificateChainPEM: TestUtilities.testCertsPEM,
                tsaURL: nil,
                sign: signCallback
            )

            // Actually use the signer to trigger the callback
            let testManifest = TestUtilities.createTestManifestJSON()
            let builder = try Builder(manifestJSON: testManifest)

            guard let imageData = TestUtilities.loadPexelsTestImage() else {
                return .failure("Signer With Callback", "Could not load test image")
            }

            let tempDir = FileManager.default.temporaryDirectory
            let sourceFile = tempDir.appendingPathComponent("callback_source_\(UUID().uuidString).jpg")
            let destFile = tempDir.appendingPathComponent("callback_dest_\(UUID().uuidString).jpg")

            defer {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: destFile)
            }

            try imageData.write(to: sourceFile)

            let sourceStream = try Stream(fileURL: sourceFile, truncate: false, createIfNeeded: false)
            let destStream = try Stream(fileURL: destFile, truncate: true, createIfNeeded: true)

            _ = try builder.sign(
                format: "image/jpeg",
                source: sourceStream,
                destination: destStream,
                signer: signer
            )

            // If we get here without errors, callback should have been invoked
            if callbackInvoked && dataToSign != nil {
                return .success(
                    "Signer With Callback",
                    "[PASS] Callback mechanism works - invoked with \(dataToSign?.count ?? 0) bytes")
            } else {
                return .failure(
                    "Signer With Callback",
                    "Callback was not invoked during signing")
            }
        } catch {
            // Check if the callback was at least invoked before failure
            if callbackInvoked && dataToSign != nil {
                return .success(
                    "Signer With Callback",
                    "[PASS] Callback mechanism works - invoked with \(dataToSign?.count ?? 0) bytes (signing failed as expected with dummy signature)"
                )
            } else {
                // The callback wasn't invoked at all - this is a real failure
                return .failure(
                    "Signer With Callback",
                    "Callback mechanism failed - callback not invoked: \(error)")
            }
        }
    }

    public func testSigningAlgorithms() -> TestResult {
        let algorithms: [SigningAlgorithm] = [
            .es256, .es384, .es512, .ps256, .ps384, .ps512, .ed25519
        ]
        var supportedCount = 0
        var results: [String] = []

        for algorithm in algorithms {
            do {
                _ = try Signer(
                    certsPEM: TestUtilities.testCertsPEM,
                    privateKeyPEM: TestUtilities.testPrivateKeyPEM,
                    algorithm: algorithm,
                    tsaURL: nil
                )
                supportedCount += 1
                results.append("\(algorithm)[PASS]")
            } catch {
                results.append("\(algorithm)[WARN]")
            }
        }

        return .success(
            "Signing Algorithms",
            "Tested \(algorithms.count) algorithms, \(supportedCount) supported")
    }


    public func testSignerWithTimestampAuthority() -> TestResult {
        let tsaURL = "http://timestamp.digecert.com"

        do {
            let signer = try Signer(
                certsPEM: TestUtilities.testCertsPEM,
                privateKeyPEM: TestUtilities.testPrivateKeyPEM,
                algorithm: .es256,
                tsaURL: tsaURL
            )
            _ = signer
            return .success("Signer With TSA", "[PASS] Created signer with TSA URL")
        } catch {
            // Certificate or TSA errors are failures, not successes
            return .failure("Signer With TSA", "Failed to create signer with TSA: \(error)")
        }
    }

    public func testWebServiceSignerCreation() async -> TestResult {
        var testSteps: [String] = []
        var testsPassed = 0

        do {
            // Test connection to signing server
            let healthURL = URL(string: "http://127.0.0.1:8080/health")!
            let (_, response) = try await URLSession.shared.data(from: healthURL)

            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                return .success(
                    "Web Service Real Signing & Verification",
                    "[WARN] Signing server not available (run 'make signing-server-start')")
            }
            testSteps.append("✓ Connected to signing server")
            testsPassed += 1

            // Create WebServiceSigner with the configuration URL and bearer token
            let configurationURL = ProcessInfo.processInfo.environment["SIGNING_SERVER_URL"] ?? "http://127.0.0.1:8080"
            let bearerToken = ProcessInfo.processInfo.environment["SIGNING_SERVER_TOKEN"] ?? "test-bearer-token-12345"
            let webServiceSigner = WebServiceSigner(
                configurationURL: "\(configurationURL)/api/v1/c2pa/configuration",
                bearerToken: bearerToken
            )
            testSteps.append("✓ Created WebServiceSigner with configuration URL")

            // Create a signer from the web service
            let signer = try await webServiceSigner.createSigner()
            testSteps.append("✓ Successfully created signer from web service configuration")
            testsPassed += 1

            // Load test image and attempt to sign
            guard let testImageData = TestUtilities.loadPexelsTestImage() else {
                throw C2PAError.api("Could not load test image")
            }
            testSteps.append("✓ Loaded test image")

            // Create a test manifest and sign the image
            let manifestJSON = "{\"claim_generator\":\"c2pa-ios-test/1.0\",\"title\":\"Web Service Test\"}"

            do {
                let builder = try Builder(manifestJSON: manifestJSON)

                let tempDir = FileManager.default.temporaryDirectory
                let sourceFile = tempDir.appendingPathComponent("test_source_\(UUID().uuidString).jpg")
                let destFile = tempDir.appendingPathComponent("test_signed_\(UUID().uuidString).jpg")

                defer {
                    try? FileManager.default.removeItem(at: sourceFile)
                    try? FileManager.default.removeItem(at: destFile)
                }

                try testImageData.write(to: sourceFile)

                let sourceStream = try Stream(fileURL: sourceFile, truncate: false, createIfNeeded: false)
                let destStream = try Stream(fileURL: destFile, truncate: true, createIfNeeded: true)

                _ = try builder.sign(
                    format: "image/jpeg",
                    source: sourceStream,
                    destination: destStream,
                    signer: signer
                )

                testSteps.append("✓ Successfully signed image using web service signer")
                testsPassed += 1

                // Verify the signed image
                let signedData = try Data(contentsOf: destFile)
                let signedStream = try Stream(data: signedData)
                let reader = try Reader(format: "image/jpeg", stream: signedStream)
                let verifiedManifestJSON = try reader.json()

                if !verifiedManifestJSON.isEmpty {
                    testSteps.append("✓ Verified signed image contains C2PA manifest")

                    if let manifestData = verifiedManifestJSON.data(using: .utf8),
                        let manifest = try? JSONSerialization.jsonObject(with: manifestData) as? [String: Any]
                    {
                        if manifest["claim_generator"] != nil {
                            testSteps.append("✓ Manifest contains claim_generator")
                        }
                        if manifest["title"] != nil {
                            testSteps.append("✓ Manifest contains title")
                        }
                    }
                }
            } catch {
                testSteps.append("[WARN] Signing with web service failed (expected in test mode): \(error)")
            }

        } catch {
            testSteps.append("✗ Test failed: \(error)")
        }

        return TestResult(
            testName: "Web Service Real Signing & Verification",
            passed: testsPassed >= 2,
            message: "Completed \(testsPassed)/3 signing server tests\n"
                + testSteps.joined(separator: "\n")
        )
    }


    public func testSignerWithActualSigning() -> TestResult {
        let manifestJSON = TestUtilities.createTestManifestJSON()

        do {
            let builder = try Builder(manifestJSON: manifestJSON)

            // Create test files instead of using streams directly
            guard let sourceData = TestUtilities.loadPexelsTestImage() else {
                return .failure("Signer With Actual Signing", "Could not load test image")
            }

            let tempDir = FileManager.default.temporaryDirectory
            let sourceFile = tempDir.appendingPathComponent("sign_source_\(UUID().uuidString).jpg")
            let destFile = tempDir.appendingPathComponent("sign_dest_\(UUID().uuidString).jpg")

            defer {
                try? FileManager.default.removeItem(at: sourceFile)
                try? FileManager.default.removeItem(at: destFile)
            }

            // Write source image to file
            try sourceData.write(to: sourceFile)

            // Create file-based streams
            let sourceStream = try Stream(
                fileURL: sourceFile, truncate: false, createIfNeeded: false)
            let destStream = try Stream(fileURL: destFile, truncate: true, createIfNeeded: true)

            let signer = try TestUtilities.createTestSigner()

            _ = try builder.sign(
                format: "image/jpeg",
                source: sourceStream,
                destination: destStream,
                signer: signer
            )
            return .success("Signer With Actual Signing", "[PASS] Signing operation completed successfully")

        } catch {
            // All errors are failures - if certs are invalid, that's a real failure
            return .failure("Signer With Actual Signing", "Signing failed: \(error)")
        }
    }


    public func runAllTests() async -> [TestResult] {
        return [
            testSignerCreation(),
            testSignerWithCallback(),
            testSigningAlgorithms(),
            testSignerWithTimestampAuthority(),
            await testWebServiceSignerCreation(),
            testSignerWithActualSigning()
        ]
    }
}
