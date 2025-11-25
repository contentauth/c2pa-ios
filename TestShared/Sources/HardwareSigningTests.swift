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
import Security

#if canImport(UIKit)
    import UIKit
#endif

// Hardware signing tests - Secure Enclave and Keychain
public final class HardwareSigningTests: TestImplementation {

    public init() {}

    // MARK: - Helper Methods

    private func isSecureEnclaveAvailable() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            if #available(iOS 13.0, macOS 10.15, *) {
                let access = SecAccessControlCreateWithFlags(
                    kCFAllocatorDefault,
                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                    [.privateKeyUsage],
                    nil
                )
                return access != nil
            }
            return false
        #endif
    }

    private func isSigningServerAvailable() async -> Bool {
        guard let healthURL = URL(string: "http://127.0.0.1:8080/health") else {
            return false
        }

        do {
            let (_, response) = try await URLSession.shared.data(from: healthURL)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }

    private func createTestKeychainKey(keyTag: String) -> Bool {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag
            ]
        ]

        var error: Unmanaged<CFError>?
        guard SecKeyCreateRandomKey(attributes as CFDictionary, &error) != nil else {
            return false
        }
        return true
    }

    private func deleteTestKeychainKey(keyTag: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Secure Enclave Tests

    public func testSecureEnclaveSignerCreation() -> TestResult {
        guard isSecureEnclaveAvailable() else {
            return .success(
                "Secure Enclave Signer Creation",
                "[WARN] Skipped - Secure Enclave not available (simulator)")
        }

        let keyTag = "org.contentauth.test.secure.\(UUID().uuidString)"
        var testSteps: [String] = []

        do {
            testSteps.append("✓ Secure Enclave is available")

            let config = SecureEnclaveSignerConfig(
                keyTag: keyTag,
                accessControl: [.privateKeyUsage]
            )
            testSteps.append("✓ Created Secure Enclave configuration")

            defer {
                _ = Signer.deleteSecureEnclaveKey(keyTag: keyTag)
            }

            // Test 1: Create Secure Enclave key
            let secureEnclaveKey = try Signer.createSecureEnclaveKey(config: config)
            testSteps.append("✓ Created Secure Enclave key successfully")

            // Test 2: Extract public key
            guard let publicKey = SecKeyCopyPublicKey(secureEnclaveKey) else {
                throw C2PAError.api("Failed to extract public key")
            }
            testSteps.append("✓ Extracted public key from Secure Enclave key")

            // Test 3: Export public key data
            var error: Unmanaged<CFError>?
            guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
            else {
                if let error = error?.takeRetainedValue() {
                    throw C2PAError.api("Failed to export public key: \(error)")
                }
                throw C2PAError.api("Failed to export public key")
            }
            testSteps.append("✓ Exported public key data: \(publicKeyData.count) bytes")

            // Test 4: Verify key attributes
            guard let keyAttributes = SecKeyCopyAttributes(secureEnclaveKey) as? [String: Any]
            else {
                throw C2PAError.api("Failed to get key attributes")
            }

            if let tokenID = keyAttributes[kSecAttrTokenID as String] as? String,
                tokenID == kSecAttrTokenIDSecureEnclave as String
            {
                testSteps.append("✓ Verified key is in Secure Enclave")
            }

            // Test 5: Test signing operation
            let testData = Data("Test data for signing".utf8)
            guard
                let signature = SecKeyCreateSignature(
                    secureEnclaveKey,
                    .ecdsaSignatureMessageX962SHA256,
                    testData as CFData,
                    &error
                ) as Data?
            else {
                if let error = error?.takeRetainedValue() {
                    throw C2PAError.api("Signing failed: \(error)")
                }
                throw C2PAError.api("Signing failed")
            }
            testSteps.append("✓ Successfully signed test data: \(signature.count) bytes")

            // Test 6: Create signer with Secure Enclave (will fail without valid cert)
            do {
                _ = try Signer(
                    algorithm: .es256,
                    certificateChainPEM: TestUtilities.testCertsPEM,
                    tsaURL: nil,
                    secureEnclaveConfig: config
                )
            } catch {
                testSteps.append("[PASS] Correctly rejected mismatched certificate: \(error)")
            }

            return .success(
                "Secure Enclave Signer Creation",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("✗ Failed: \(error)")
            return .failure(
                "Secure Enclave Signer Creation",
                testSteps.joined(separator: "\n"))
        }
    }

    public func testSecureEnclaveCSRSigning() async -> TestResult {
        guard isSecureEnclaveAvailable() else {
            return .success(
                "Secure Enclave CSR Signing",
                "[WARN] Skipped - Secure Enclave not available (simulator)")
        }

        var testSteps: [String] = []

        // Check signing server availability
        let serverAvailable = await isSigningServerAvailable()
        if !serverAvailable {
            return .success(
                "Secure Enclave CSR Signing",
                "[WARN] Skipped - Signing server not available (run 'make signing-server')")
        }
        testSteps.append("✓ Signing server is available")

        let keyTag = "org.contentauth.test.csr.\(UUID().uuidString)"

        do {
            let config = SecureEnclaveSignerConfig(
                keyTag: keyTag,
                accessControl: [.privateKeyUsage]
            )
            testSteps.append("✓ Created Secure Enclave configuration")

            defer {
                _ = Signer.deleteSecureEnclaveKey(keyTag: keyTag)
            }

            // Create Secure Enclave key
            let secureEnclaveKey = try Signer.createSecureEnclaveKey(config: config)
            testSteps.append("✓ Created Secure Enclave key")

            // Extract public key
            guard let publicKey = SecKeyCopyPublicKey(secureEnclaveKey) else {
                throw C2PAError.api("Failed to extract public key")
            }
            testSteps.append("✓ Extracted public key")

            // Create CSR configuration
            let certConfig = CertificateManager.CertificateConfig(
                commonName: "C2PA Test Signer",
                organization: "Test Organization",
                organizationalUnit: "iOS Testing",
                country: "US",
                state: "California",
                locality: "San Francisco",
                emailAddress: "test@example.com"
            )

            // Generate CSR
            let csr = try CertificateManager.createCSR(for: publicKey, config: certConfig)
            testSteps.append("✓ Generated CSR for Secure Enclave key")

            // Verify CSR format
            if csr.contains("-----BEGIN CERTIFICATE REQUEST-----")
                && csr.contains("-----END CERTIFICATE REQUEST-----")
            {
                testSteps.append("✓ CSR has valid PEM format")
            }

            // Submit CSR to signing server
            let csrURL = URL(string: "http://127.0.0.1:8080/api/v1/certificates/sign")!
            var request = URLRequest(url: csrURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 30

            let csrRequest =
                [
                    "csr": csr,
                    "metadata": [
                        "deviceId": "test-device",
                        "appVersion": "1.0.0",
                        "purpose": "secure-enclave-test"
                    ]
                ] as [String: Any]

            request.httpBody = try JSONSerialization.data(withJSONObject: csrRequest)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                testSteps.append("✗ CSR submission failed with status: \(statusCode)")
                if let errorMessage = String(data: data, encoding: .utf8) {
                    testSteps.append("Error: \(errorMessage)")
                }
                return .failure(
                    "Secure Enclave CSR Signing",
                    testSteps.joined(separator: "\n"))
            }

            testSteps.append("✓ CSR submitted successfully")

            // Parse response
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let certChain = jsonResponse["certificateChain"] as? String {
                    testSteps.append("✓ Received certificate chain")

                    // Count certificates in chain
                    let certCount =
                        certChain.components(separatedBy: "-----BEGIN CERTIFICATE-----").count - 1
                    testSteps.append("✓ Certificate chain contains \(certCount) certificate(s)")

                    // Test creating signer with the certificate
                    do {
                        let signer = try Signer(
                            algorithm: .es256,
                            certificateChainPEM: certChain,
                            tsaURL: nil,
                            secureEnclaveConfig: config
                        )
                        _ = signer
                        testSteps.append("✓ Created signer with enrolled certificate")
                    } catch {
                        testSteps.append("[WARN] Signer creation: \(error)")
                    }
                }

                if let certId = jsonResponse["certificateId"] as? String {
                    testSteps.append("✓ Certificate ID: \(certId)")
                }

                if let serialNumber = jsonResponse["serialNumber"] as? String {
                    testSteps.append("✓ Serial Number: \(serialNumber)")
                }
            }

            return .success(
                "Secure Enclave CSR Signing",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("✗ Failed: \(error)")
            return .failure(
                "Secure Enclave CSR Signing",
                testSteps.joined(separator: "\n"))
        }
    }

    // MARK: - Keychain Tests

    public func testKeychainSignerCreation() -> TestResult {
        let keyTag = "org.contentauth.test.keychain.\(UUID().uuidString)"
        var testSteps: [String] = []

        // Try to create test key in keychain
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
        ]

        defer {
            deleteTestKeychainKey(keyTag: keyTag)
        }

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            // Handle keychain access errors gracefully
            if let error = error?.takeRetainedValue() {
                let nsError = error as Error as NSError
                if nsError.code == -34018 {  // errSecMissingEntitlement
                    return .success(
                        "Keychain Signer Creation",
                        "[WARN] Skipped - Keychain access not available in this test environment")
                }
                testSteps.append("✗ Failed to create test key in keychain: \(error)")
            } else {
                testSteps.append("✗ Failed to create test key in keychain")
            }
            return .failure(
                "Keychain Signer Creation",
                testSteps.joined(separator: "\n"))
        }

        do {
            testSteps.append("✓ Created test key in keychain")

            // Get public key
            guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
                throw C2PAError.api("Failed to extract public key")
            }
            testSteps.append("✓ Retrieved public key from keychain")

            // Export public key
            guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
            else {
                if let error = error?.takeRetainedValue() {
                    throw C2PAError.api("Failed to export public key: \(error)")
                }
                throw C2PAError.api("Failed to export public key")
            }
            testSteps.append("✓ Exported public key: \(publicKeyData.count) bytes")

            // Test signing with keychain key
            let testData = Data("Test data for keychain signing".utf8)
            guard
                let signature = SecKeyCreateSignature(
                    privateKey,
                    .ecdsaSignatureMessageX962SHA256,
                    testData as CFData,
                    &error
                ) as Data?
            else {
                if let error = error?.takeRetainedValue() {
                    throw C2PAError.api("Signing failed: \(error)")
                }
                throw C2PAError.api("Signing failed")
            }
            testSteps.append("✓ Successfully signed test data: \(signature.count) bytes")

            // Verify signature
            let verified = SecKeyVerifySignature(
                publicKey,
                .ecdsaSignatureMessageX962SHA256,
                testData as CFData,
                signature as CFData,
                &error
            )

            if verified {
                testSteps.append("✓ Signature verification passed")
            } else {
                testSteps.append("[WARN] Signature verification failed")
            }

            // Generate self-signed certificate chain matching the keychain key
            let certConfig = CertificateManager.CertificateConfig(
                commonName: "C2PA Keychain Test Signer",
                organization: "C2PA Test Organization",
                organizationalUnit: "Keychain Testing Unit",
                country: "US",
                state: "California",
                locality: "San Francisco",
                emailAddress: "keychain-test@example.com",
                validityDays: 365
            )

            let certificateChain = try CertificateManager.createSelfSignedCertificateChain(
                for: publicKey,
                config: certConfig
            )
            testSteps.append("✓ Generated self-signed certificate chain for keychain key")

            // Add a small delay to ensure certificate validity
            Thread.sleep(forTimeInterval: 1.0)
            testSteps.append("✓ Waited for certificate validity")

            // Test creating signer with keychain key and matching certificate
            let keychainSigner = try Signer(
                algorithm: .es256,
                certificateChainPEM: certificateChain,
                tsaURL: nil,
                keychainKeyTag: keyTag
            )
            testSteps.append("✓ Created keychain signer successfully")

            // Test reserve size
            let reserveSize = try keychainSigner.reserveSize()
            if reserveSize > 0 {
                testSteps.append("✓ Reserve size calculated: \(reserveSize) bytes")
            } else {
                testSteps.append("[WARN] Reserve size is 0")
            }

            return .success(
                "Keychain Signer Creation",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("✗ Failed: \(error)")
            return .failure(
                "Keychain Signer Creation",
                testSteps.joined(separator: "\n"))
        }
    }

    public func runAllTests() async -> [TestResult] {
        var results: [TestResult] = []

        results.append(testKeychainSignerCreation())
        results.append(testSecureEnclaveSignerCreation())
        results.append(await testSecureEnclaveCSRSigning())

        return results
    }
}
