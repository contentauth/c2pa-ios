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
//  ManifestDefinition.swift
//

import Foundation

/// A definition for creating a C2PA manifest.
///
/// `ManifestDefinition` describes the structure and content of a C2PA manifest,
/// including assertions about the content, its provenance, and ingredients used.
///
/// Assertions are divided into two categories:
/// - ``assertions`` -- created assertions that the signer is authoring
/// - ``gatheredAssertions`` -- assertions gathered from external sources (e.g., CAWG identity)
///
/// ## Example
///
/// ```swift
/// let manifest = ManifestDefinition.created(
///     title: "photo.jpg",
///     claimGeneratorInfo: ClaimGeneratorInfo(name: "MyApp", version: "1.0"),
///     digitalSourceType: .digitalCapture
/// )
/// let json = try manifest.toJSON()
/// ```
///
/// - SeeAlso: [Manifest Definition Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema)
public struct ManifestDefinition: Codable, CustomStringConvertible, Equatable {
    public enum CodingKeys: String, CodingKey {
        case assertions
        case claimGeneratorInfo = "claim_generator_info"
        case claimVersion = "claim_version"
        case format
        case gatheredAssertions = "gathered_assertions"
        case ingredients
        case instanceId = "instance_id"
        case label
        case metadata
        case redactions
        case thumbnail
        case title
        case vendor
    }

    // MARK: - Properties

    /// Created assertions that the signer is authoring.
    public var assertions: [AssertionDefinition]

    /// Claim Generator Info is always required with at least one entry.
    public var claimGeneratorInfo: [ClaimGeneratorInfo]

    /// The version of the claim. Defaults to 2 for C2PA 2.x spec compliance.
    public var claimVersion: UInt8

    /// The format of the source file as a MIME type.
    public var format: String

    /// Gathered assertions from external sources (e.g., CAWG identity assertions).
    ///
    /// CAWG identity assertions should be placed here, not in ``assertions``.
    public var gatheredAssertions: [AssertionDefinition]

    /// A list of ingredients.
    public var ingredients: [Ingredient]

    /// Instance ID from xmpMM:InstanceID in XMP metadata.
    public var instanceId: String?

    /// Pre-defined manifest label. Must be unique. Not intended for general use.
    public var label: String?

    /// Optional manifest metadata.
    @available(*, deprecated, message: "This will be deprecated in the future; not recommended to use.")
    public var metadata: [Metadata]?

    /// A list of redactions -- URIs to redacted assertions.
    public var redactions: [String]?

    /// An optional ``ResourceRef`` to a thumbnail image.
    public var thumbnail: ResourceRef?

    /// A human-readable title, generally source filename.
    public var title: String

    /// Optional prefix added to the generated manifest label (typically a reverse domain name).
    public var vendor: String?

    // MARK: - Initialization

    /// Creates a manifest definition.
    ///
    /// - Parameters:
    ///   - assertions: Created assertions.
    ///   - claimGeneratorInfo: Required claim generator info (at least one entry).
    ///   - claimVersion: The claim version. Defaults to 2.
    ///   - format: The MIME type of the source file.
    ///   - gatheredAssertions: Gathered assertions from external sources.
    ///   - ingredients: A list of ingredients.
    ///   - instanceId: Instance ID from XMP metadata.
    ///   - label: Pre-defined manifest label.
    ///   - redactions: URIs to redacted assertions.
    ///   - thumbnail: A thumbnail image reference.
    ///   - title: A human-readable title.
    ///   - vendor: Prefix for the generated manifest label.
    public init(
        assertions: [AssertionDefinition] = [],
        claimGeneratorInfo: [ClaimGeneratorInfo],
        claimVersion: UInt8 = 2,
        format: String = "application/octet-stream",
        gatheredAssertions: [AssertionDefinition] = [],
        ingredients: [Ingredient] = [],
        instanceId: String? = nil,
        label: String? = nil,
        redactions: [String]? = nil,
        thumbnail: ResourceRef? = nil,
        title: String,
        vendor: String? = nil
    ) {
        self.assertions = assertions
        self.claimGeneratorInfo = claimGeneratorInfo
        self.claimVersion = claimVersion
        self.format = format
        self.gatheredAssertions = gatheredAssertions
        self.ingredients = ingredients
        self.instanceId = instanceId
        self.label = label
        self.redactions = redactions
        self.thumbnail = thumbnail
        self.title = title
        self.vendor = vendor
    }

    // MARK: - Factory Methods

    /// Creates a manifest for a newly created asset.
    ///
    /// - Parameters:
    ///   - title: A human-readable title.
    ///   - claimGeneratorInfo: The claim generator info.
    ///   - digitalSourceType: The type of digital source.
    /// - Returns: A manifest definition configured for creation.
    public static func created(
        title: String,
        claimGeneratorInfo: ClaimGeneratorInfo,
        digitalSourceType: DigitalSourceType
    ) -> ManifestDefinition {
        ManifestDefinition(
            assertions: [
                .actions(actions: [
                    Action(
                        action: .created,
                        digitalSourceType: digitalSourceType
                    ),
                ]),
            ],
            claimGeneratorInfo: [claimGeneratorInfo],
            title: title
        )
    }

    /// Creates a manifest for an edited asset.
    ///
    /// - Parameters:
    ///   - title: A human-readable title.
    ///   - claimGeneratorInfo: The claim generator info.
    ///   - parentIngredient: The parent ingredient being edited.
    ///   - editActions: The editing actions performed.
    /// - Returns: A manifest definition configured for editing.
    public static func edited(
        title: String,
        claimGeneratorInfo: ClaimGeneratorInfo,
        parentIngredient: Ingredient,
        editActions: [Action]
    ) -> ManifestDefinition {
        ManifestDefinition(
            assertions: [.actions(actions: editActions)],
            claimGeneratorInfo: [claimGeneratorInfo],
            ingredients: [parentIngredient],
            title: title
        )
    }

    /// Creates a manifest with explicit created and gathered assertions.
    ///
    /// - Parameters:
    ///   - title: A human-readable title.
    ///   - claimGeneratorInfo: The claim generator info.
    ///   - createdAssertions: Assertions authored by the signer.
    ///   - gatheredAssertions: Assertions gathered from external sources.
    ///   - ingredients: A list of ingredients.
    /// - Returns: A configured manifest definition.
    public static func withAssertions(
        title: String,
        claimGeneratorInfo: ClaimGeneratorInfo,
        createdAssertions: [AssertionDefinition],
        gatheredAssertions: [AssertionDefinition] = [],
        ingredients: [Ingredient] = []
    ) -> ManifestDefinition {
        ManifestDefinition(
            assertions: createdAssertions,
            claimGeneratorInfo: [claimGeneratorInfo],
            gatheredAssertions: gatheredAssertions,
            ingredients: ingredients,
            title: title
        )
    }

    /// Creates a manifest with a CAWG identity assertion in gathered assertions.
    ///
    /// - Parameters:
    ///   - title: A human-readable title.
    ///   - claimGeneratorInfo: The claim generator info.
    ///   - createdAssertions: Assertions authored by the signer.
    ///   - cawgIdentityAssertion: The CAWG identity assertion (placed in gathered assertions).
    ///   - ingredients: A list of ingredients.
    /// - Returns: A configured manifest definition.
    public static func withCawgIdentity(
        title: String,
        claimGeneratorInfo: ClaimGeneratorInfo,
        createdAssertions: [AssertionDefinition],
        cawgIdentityAssertion: AssertionDefinition,
        ingredients: [Ingredient] = []
    ) -> ManifestDefinition {
        ManifestDefinition(
            assertions: createdAssertions,
            claimGeneratorInfo: [claimGeneratorInfo],
            gatheredAssertions: [cawgIdentityAssertion],
            ingredients: ingredients,
            title: title
        )
    }

    // MARK: - Convenience

    /// Returns the unique base labels of the created assertions.
    public func createdAssertionLabels() -> [String] {
        Array(Set(assertions.map { $0.baseLabel }))
    }

    /// Encodes this manifest to a JSON string.
    ///
    /// - Returns: A JSON string representation.
    /// - Throws: `EncodingError` if encoding fails.
    public func toJSON() throws -> String {
        try C2PAJson.encode(self)
    }

    /// Encodes this manifest to a pretty-printed JSON string.
    ///
    /// - Returns: A formatted JSON string representation.
    /// - Throws: `EncodingError` if encoding fails.
    public func toPrettyJSON() throws -> String {
        try C2PAJson.encodePretty(self)
    }

    /// Decodes a manifest from a JSON string.
    ///
    /// - Parameter json: A JSON string to decode.
    /// - Returns: The decoded manifest definition.
    /// - Throws: `DecodingError` if decoding fails.
    public static func fromJSON(_ json: String) throws -> ManifestDefinition {
        try C2PAJson.decode(ManifestDefinition.self, from: json)
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        do {
            return try toJSON()
        } catch {
            return "<ERROR encoding: \(error.localizedDescription)>"
        }
    }
}
