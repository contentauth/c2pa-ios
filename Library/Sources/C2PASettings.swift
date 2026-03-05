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
//  C2PASettings.swift
//

import C2PAC
import Foundation

/// Manages C2PA settings configuration.
///
/// `C2PASettings` provides a Swift-idiomatic interface for loading and applying
/// C2PA settings in JSON or TOML format. Settings control signer configuration,
/// CAWG identity assertions, thumbnail generation, and other build options.
///
/// ## Example
///
/// ```swift
/// let settings = try C2PASettings(json: settingsJSON)
/// let signer = try Signer(settingsJSON: settingsJSON)
/// ```
///
/// ```swift
/// let settings = try C2PASettings(toml: settingsTOML)
/// ```
///
/// - SeeAlso: ``Signer``, ``SettingsValidator``
public final class C2PASettings {
    private var settingsString: String
    private var format: String

    /// Creates settings from a JSON string.
    ///
    /// - Parameter json: A JSON string containing C2PA settings.
    /// - Throws: ``C2PAError`` if the JSON is invalid.
    public init(json: String) throws {
        self.settingsString = json
        self.format = "json"
        try apply()
    }

    /// Creates settings from a TOML string.
    ///
    /// - Parameter toml: A TOML string containing C2PA settings.
    /// - Throws: ``C2PAError`` if the TOML is invalid.
    public init(toml: String) throws {
        self.settingsString = toml
        self.format = "toml"
        try apply()
    }

    /// Loads additional JSON settings, merging with existing configuration.
    ///
    /// - Parameter json: A JSON string containing C2PA settings to merge.
    /// - Throws: ``C2PAError`` if the JSON is invalid.
    public func load(json: String) throws {
        self.settingsString = json
        self.format = "json"
        try apply()
    }

    /// Loads additional TOML settings, merging with existing configuration.
    ///
    /// - Parameter toml: A TOML string containing C2PA settings to merge.
    /// - Throws: ``C2PAError`` if the TOML is invalid.
    public func load(toml: String) throws {
        self.settingsString = toml
        self.format = "toml"
        try apply()
    }

    /// Validates the current settings without applying them.
    ///
    /// - Returns: A ``ValidationResult`` with any errors and warnings.
    public func validate() -> ValidationResult {
        if format == "json" {
            return SettingsValidator.validate(settingsString)
        }
        // TOML validation is not yet implemented
        return .valid
    }

    /// Creates a ``Signer`` from the loaded settings.
    ///
    /// - Returns: A configured ``Signer`` instance.
    /// - Throws: ``C2PAError`` if a signer cannot be created from the settings.
    public func createSigner() throws -> Signer {
        if format == "json" {
            return try Signer(settingsJSON: settingsString)
        } else {
            return try Signer(settingsTOML: settingsString)
        }
    }

    // MARK: - Private

    private func apply() throws {
        try settingsString.withCString { settingsPtr in
            try format.withCString { formatPtr in
                let result = c2pa_load_settings(settingsPtr, formatPtr)
                guard result == 0 else {
                    throw C2PAError.api(lastC2PAError())
                }
            }
        }
    }
}
