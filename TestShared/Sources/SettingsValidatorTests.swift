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

public final class SettingsValidatorTests: TestImplementation {

    public init() {}

    public func testValidSettingsJSON() -> TestResult {
        let json = """
        {
            "version": 1,
            "signer": {
                "alg": "es256",
                "sign_cert": "-----BEGIN CERTIFICATE-----\\ntest\\n-----END CERTIFICATE-----",
                "private_key": "-----BEGIN PRIVATE KEY-----\\ntest\\n-----END PRIVATE KEY-----",
                "tsa_url": "http://timestamp.example.com"
            },
            "thumbnail": {
                "format": "jpeg",
                "quality": "medium"
            },
            "intent": "Edit"
        }
        """
        let result = SettingsValidator.validate(json)
        guard result.isValid else {
            return .failure("Valid Settings", "Expected valid, got errors: \(result.errors)")
        }
        guard !result.hasWarnings else {
            return .failure("Valid Settings", "Expected no warnings, got: \(result.warnings)")
        }
        return .success("Valid Settings", "[PASS] Valid settings JSON accepted")
    }

    public func testInvalidJSON() -> TestResult {
        let result = SettingsValidator.validate("not json at all {{{")
        guard !result.isValid else {
            return .failure("Invalid JSON", "Expected errors for malformed JSON")
        }
        guard result.errors.first?.contains("not valid JSON") == true else {
            return .failure("Invalid JSON", "Expected JSON parse error, got: \(result.errors)")
        }
        return .success("Invalid JSON", "[PASS] Malformed JSON rejected")
    }

    public func testWrongVersion() -> TestResult {
        let json = """
        {"version": 2}
        """
        let result = SettingsValidator.validate(json)
        guard !result.isValid else {
            return .failure("Wrong Version", "Expected error for unsupported version")
        }
        guard result.errors.first?.contains("Unsupported settings version") == true else {
            return .failure("Wrong Version", "Expected version error, got: \(result.errors)")
        }
        return .success("Wrong Version", "[PASS] Wrong version rejected")
    }

    public func testMissingVersion() -> TestResult {
        let json = """
        {"signer": {}}
        """
        let result = SettingsValidator.validate(json)
        guard result.isValid else {
            return .failure("Missing Version", "Expected valid (warning only), got errors: \(result.errors)")
        }
        guard result.warnings.contains(where: { $0.contains("Missing 'version'") }) else {
            return .failure("Missing Version", "Expected version warning, got: \(result.warnings)")
        }
        return .success("Missing Version", "[PASS] Missing version produces warning")
    }

    public func testUnknownTopLevelKeys() -> TestResult {
        let json = """
        {"version": 1, "unknown_key": true, "another": 42}
        """
        let result = SettingsValidator.validate(json)
        guard result.warnings.contains(where: { $0.contains("Unknown top-level key") }) else {
            return .failure("Unknown Keys", "Expected warning about unknown keys, got: \(result.warnings)")
        }
        return .success("Unknown Keys", "[PASS] Unknown top-level keys produce warnings")
    }

    public func testInvalidAlgorithm() -> TestResult {
        let json = """
        {"version": 1, "signer": {"alg": "rsa1024"}}
        """
        let result = SettingsValidator.validate(json)
        guard result.errors.contains(where: { $0.contains("Invalid signing algorithm") }) else {
            return .failure("Invalid Algorithm", "Expected algorithm error, got: \(result.errors)")
        }
        return .success("Invalid Algorithm", "[PASS] Invalid algorithm rejected")
    }

    public func testValidAlgorithms() -> TestResult {
        let algorithms = ["es256", "es384", "es512", "ps256", "ps384", "ps512", "ed25519"]
        for alg in algorithms {
            let json = """
            {"version": 1, "signer": {"alg": "\(alg)"}}
            """
            let result = SettingsValidator.validate(json)
            if result.errors.contains(where: { $0.contains("Invalid signing algorithm") }) {
                return .failure("Valid Algorithms", "Algorithm '\(alg)' should be valid")
            }
        }
        return .success("Valid Algorithms", "[PASS] All 7 valid algorithms accepted")
    }

    public func testInvalidCertPEM() -> TestResult {
        let json = """
        {"version": 1, "signer": {"sign_cert": "not a pem cert"}}
        """
        let result = SettingsValidator.validate(json)
        guard result.errors.contains(where: { $0.contains("PEM format") && $0.contains("sign_cert") }) else {
            return .failure("Invalid Cert PEM", "Expected PEM format error, got: \(result.errors)")
        }
        return .success("Invalid Cert PEM", "[PASS] Invalid cert PEM rejected")
    }

    public func testInvalidPrivateKeyPEM() -> TestResult {
        let json = """
        {"version": 1, "signer": {"private_key": "not a pem key"}}
        """
        let result = SettingsValidator.validate(json)
        guard result.errors.contains(where: { $0.contains("PEM format") && $0.contains("private_key") }) else {
            return .failure("Invalid Key PEM", "Expected PEM format error, got: \(result.errors)")
        }
        return .success("Invalid Key PEM", "[PASS] Invalid private key PEM rejected")
    }

    public func testInvalidTsaUrl() -> TestResult {
        let json = """
        {"version": 1, "signer": {"tsa_url": ""}}
        """
        let result = SettingsValidator.validate(json)
        guard result.errors.contains(where: { $0.contains("tsa_url") && $0.contains("not a valid URL") }) else {
            return .failure("Invalid TSA URL", "Expected URL error, got: \(result.errors)")
        }
        return .success("Invalid TSA URL", "[PASS] Invalid TSA URL rejected")
    }

    public func testCawgSignerLocalValidation() -> TestResult {
        let json = """
        {"version": 1, "cawg_x509_signer": {"local": {"alg": "invalid_alg"}}}
        """
        let result = SettingsValidator.validate(json)
        guard result.errors.contains(where: { $0.contains("Invalid signing algorithm") }) else {
            return .failure("CAWG Signer", "Expected algorithm error for CAWG local signer, got: \(result.errors)")
        }
        return .success("CAWG Signer", "[PASS] CAWG local signer validation works")
    }

    public func testInvalidThumbnailFormat() -> TestResult {
        let json = """
        {"version": 1, "thumbnail": {"format": "bmp"}}
        """
        let result = SettingsValidator.validate(json)
        guard result.warnings.contains(where: { $0.contains("Unknown thumbnail format") }) else {
            return .failure("Invalid Thumb Format", "Expected format warning, got: \(result.warnings)")
        }
        return .success("Invalid Thumb Format", "[PASS] Invalid thumbnail format produces warning")
    }

    public func testInvalidThumbnailQuality() -> TestResult {
        let json = """
        {"version": 1, "thumbnail": {"quality": "ultra"}}
        """
        let result = SettingsValidator.validate(json)
        guard result.warnings.contains(where: { $0.contains("Unknown thumbnail quality") }) else {
            return .failure("Invalid Thumb Quality", "Expected quality warning, got: \(result.warnings)")
        }
        return .success("Invalid Thumb Quality", "[PASS] Invalid thumbnail quality produces warning")
    }

    public func testValidThumbnailSection() -> TestResult {
        let json = """
        {"version": 1, "thumbnail": {"format": "jpeg", "quality": "medium"}}
        """
        let result = SettingsValidator.validate(json)
        guard !result.warnings.contains(where: { $0.contains("thumbnail") }) else {
            return .failure("Valid Thumbnail", "Should not warn for valid thumbnail, got: \(result.warnings)")
        }
        return .success("Valid Thumbnail", "[PASS] Valid thumbnail section accepted")
    }

    public func testInvalidIntent() -> TestResult {
        let json = """
        {"version": 1, "intent": "Delete"}
        """
        let result = SettingsValidator.validate(json)
        guard result.warnings.contains(where: { $0.contains("Unknown intent") }) else {
            return .failure("Invalid Intent", "Expected intent warning, got: \(result.warnings)")
        }
        return .success("Invalid Intent", "[PASS] Invalid intent produces warning")
    }

    public func testValidIntent() -> TestResult {
        let json = """
        {"version": 1, "intent": "Edit"}
        """
        let result = SettingsValidator.validate(json)
        guard !result.warnings.contains(where: { $0.contains("intent") }) else {
            return .failure("Valid Intent", "Should not warn for valid intent, got: \(result.warnings)")
        }
        return .success("Valid Intent", "[PASS] Valid intent accepted")
    }

    public func runAllTests() async -> [TestResult] {
        return [
            testValidSettingsJSON(),
            testInvalidJSON(),
            testWrongVersion(),
            testMissingVersion(),
            testUnknownTopLevelKeys(),
            testInvalidAlgorithm(),
            testValidAlgorithms(),
            testInvalidCertPEM(),
            testInvalidPrivateKeyPEM(),
            testInvalidTsaUrl(),
            testCawgSignerLocalValidation(),
            testInvalidThumbnailFormat(),
            testInvalidThumbnailQuality(),
            testValidThumbnailSection(),
            testInvalidIntent(),
            testValidIntent()
        ]
    }
}
