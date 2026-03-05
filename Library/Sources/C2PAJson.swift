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
//  C2PAJson.swift
//

import Foundation

/// Centralized JSON encoding and decoding for all C2PA types.
///
/// Use `C2PAJson` for all JSON operations within the library to ensure
/// consistent configuration (key strategies, date formatting, etc.).
///
/// ## Example
///
/// ```swift
/// let json = try C2PAJson.encode(manifest)
/// let pretty = try C2PAJson.encodePretty(manifest)
/// let decoded = try C2PAJson.decode(ManifestDefinition.self, from: jsonString)
/// ```
public enum C2PAJson {
    /// Shared encoder configured for C2PA JSON conventions.
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    /// Shared encoder configured for pretty-printed C2PA JSON.
    public static let prettyEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    /// Shared decoder configured for C2PA JSON conventions.
    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    /// Encodes a value to a JSON string.
    ///
    /// - Parameter value: The value to encode.
    /// - Returns: A JSON string representation.
    /// - Throws: `EncodingError` if encoding fails.
    public static func encode<T: Encodable>(_ value: T) throws -> String {
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw C2PAError.utf8
        }
        return string
    }

    /// Encodes a value to a pretty-printed JSON string.
    ///
    /// - Parameter value: The value to encode.
    /// - Returns: A formatted JSON string representation.
    /// - Throws: `EncodingError` if encoding fails.
    public static func encodePretty<T: Encodable>(_ value: T) throws -> String {
        let data = try prettyEncoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw C2PAError.utf8
        }
        return string
    }

    /// Decodes a value from a JSON string.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - json: A JSON string to decode from.
    /// - Returns: The decoded value.
    /// - Throws: `DecodingError` if decoding fails.
    public static func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        guard let data = json.data(using: .utf8) else {
            throw C2PAError.utf8
        }
        return try decoder.decode(type, from: data)
    }

    /// Decodes a value from JSON data.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - data: JSON data to decode from.
    /// - Returns: The decoded value.
    /// - Throws: `DecodingError` if decoding fails.
    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
