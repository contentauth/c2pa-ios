// This file is licensed to you under the Apache License, Version 2.0
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE
// files for the specific language governing permissions and limitations under
// each license.
//
//  SettingsValidator.swift
//

import Foundation

/// Validates C2PA settings JSON for schema compliance.
///
/// `SettingsValidator` checks settings configurations before they are applied,
/// catching common errors like invalid algorithms, malformed certificate chains,
/// and unsupported configuration keys.
///
/// ## Example
///
/// ```swift
/// let result = SettingsValidator.validate(settingsJSON)
/// if !result.isValid {
///     for error in result.errors {
///         print("Settings error: \(error)")
///     }
/// }
/// ```
///
/// - SeeAlso: ``ValidationResult``, ``ManifestValidator``
public enum SettingsValidator {
    /// The current supported settings version.
    public static let supportedVersion = 1

    /// Valid signing algorithm identifiers.
    public static let validAlgorithms: Set<String> = [
        "es256", "es384", "es512", "ps256", "ps384", "ps512", "ed25519",
    ]

    /// Valid thumbnail image formats.
    public static let validThumbnailFormats: Set<String> = [
        "jpeg", "png", "webp",
    ]

    /// Valid thumbnail quality levels.
    public static let validThumbnailQualities: Set<String> = [
        "low", "medium", "high",
    ]

    /// Valid builder intent strings.
    public static let validIntents: Set<String> = [
        "Edit", "Update",
    ]

    // MARK: - Known Top-Level Keys

    private static let knownTopLevelKeys: Set<String> = [
        "version", "intent", "thumbnail", "builder", "signer",
        "trust", "cawg_x509_signer", "verify",
    ]

    // MARK: - Validation

    /// Validates a settings JSON string.
    ///
    /// - Parameter settingsJSON: The JSON string to validate.
    /// - Returns: A ``ValidationResult`` with any errors and warnings.
    public static func validate(_ settingsJSON: String) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []

        guard let data = settingsJSON.data(using: .utf8) else {
            return ValidationResult(errors: ["Settings string is not valid UTF-8"])
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ValidationResult(errors: ["Settings is not valid JSON or not a JSON object"])
        }

        // Version check
        if let version = json["version"] as? Int {
            if version != supportedVersion {
                errors.append("Unsupported settings version \(version); expected \(supportedVersion)")
            }
        } else {
            warnings.append("Missing 'version' field; expected \(supportedVersion)")
        }

        // Unknown top-level keys
        for key in json.keys where !knownTopLevelKeys.contains(key) {
            warnings.append("Unknown top-level key '\(key)'")
        }

        // Validate signer section
        if let signer = json["signer"] as? [String: Any] {
            validateSignerSection(signer, errors: &errors, warnings: &warnings)
        }

        // Validate CAWG signer section
        if let cawg = json["cawg_x509_signer"] as? [String: Any] {
            if let local = cawg["local"] as? [String: Any] {
                validateSignerSection(local, errors: &errors, warnings: &warnings)
            }
        }

        // Validate thumbnail section
        if let thumbnail = json["thumbnail"] as? [String: Any] {
            validateThumbnailSection(thumbnail, warnings: &warnings)
        }

        // Validate intent
        if let intent = json["intent"] as? String {
            if !validIntents.contains(intent) {
                warnings.append("Unknown intent '\(intent)'; expected one of: \(validIntents.sorted().joined(separator: ", "))")
            }
        }

        return ValidationResult(errors: errors, warnings: warnings)
    }

    // MARK: - Private

    private static func validateSignerSection(
        _ signer: [String: Any],
        errors: inout [String],
        warnings: inout [String]
    ) {
        // Algorithm
        if let alg = signer["alg"] as? String {
            if !validAlgorithms.contains(alg.lowercased()) {
                errors.append("Invalid signing algorithm '\(alg)'; valid algorithms: \(validAlgorithms.sorted().joined(separator: ", "))")
            }
        }

        // Certificate chain format
        if let cert = signer["sign_cert"] as? String {
            if !cert.contains("BEGIN CERTIFICATE") {
                errors.append("sign_cert does not appear to be in PEM format (missing BEGIN CERTIFICATE)")
            }
        }

        // Private key format
        if let key = signer["private_key"] as? String {
            if !key.contains("BEGIN") {
                errors.append("private_key does not appear to be in PEM format (missing BEGIN marker)")
            }
        }

        // TSA URL
        if let tsaURL = signer["tsa_url"] as? String {
            if URL(string: tsaURL) == nil {
                errors.append("tsa_url is not a valid URL: \(tsaURL)")
            }
        }
    }

    private static func validateThumbnailSection(
        _ thumbnail: [String: Any],
        warnings: inout [String]
    ) {
        if let format = thumbnail["format"] as? String {
            if !validThumbnailFormats.contains(format.lowercased()) {
                warnings.append("Unknown thumbnail format '\(format)'; valid formats: \(validThumbnailFormats.sorted().joined(separator: ", "))")
            }
        }

        if let quality = thumbnail["quality"] as? String {
            if !validThumbnailQualities.contains(quality.lowercased()) {
                warnings.append("Unknown thumbnail quality '\(quality)'; valid qualities: \(validThumbnailQualities.sorted().joined(separator: ", "))")
            }
        }
    }
}
