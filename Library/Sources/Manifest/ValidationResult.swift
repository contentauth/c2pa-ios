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
//  ValidationResult.swift
//

import Foundation

/// The result of validating a manifest or settings configuration.
///
/// `ValidationResult` collects errors and warnings encountered during validation.
/// A result with no errors is considered valid.
///
/// ## Example
///
/// ```swift
/// let result = ManifestValidator.validate(manifest)
/// if result.isValid {
///     // Manifest passes validation
/// } else {
///     for error in result.errors {
///         print("Error: \(error)")
///     }
/// }
/// ```
///
/// - SeeAlso: ``ManifestValidator``, ``SettingsValidator``
public struct ValidationResult: Sendable {
    /// Validation errors that must be resolved.
    public let errors: [String]

    /// Validation warnings that indicate potential issues.
    public let warnings: [String]

    /// Whether the result contains any errors.
    public var hasErrors: Bool { !errors.isEmpty }

    /// Whether the result contains any warnings.
    public var hasWarnings: Bool { !warnings.isEmpty }

    /// Whether the validation passed (no errors).
    public var isValid: Bool { !hasErrors }

    /// Creates a validation result.
    ///
    /// - Parameters:
    ///   - errors: Validation errors.
    ///   - warnings: Validation warnings.
    public init(errors: [String] = [], warnings: [String] = []) {
        self.errors = errors
        self.warnings = warnings
    }

    /// A valid result with no errors or warnings.
    public static let valid = ValidationResult()
}
