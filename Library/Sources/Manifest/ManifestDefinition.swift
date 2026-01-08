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
/// - SeeAlso: [Manifest Definition Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema)
public struct ManifestDefinition: Codable, CustomStringConvertible, Equatable {

    // MARK: ManifestDefinition

    public enum CodingKeys: String, CodingKey {
        case assertions
        case claimGeneratorInfo = "claim_generator_info"
        case claimVersion = "claim_version"
        case format
        case ingredients
        case instanceId = "instance_id"
        case label
        case metadata
        case redactions
        case thumbnail
        case title
        case vendor
    }


    static let jsonDecoder = JSONDecoder()
    static let jsonEncoder = JSONEncoder()


    /// A list of assertions.
    public var assertions: [AssertionDefinition]

    /// Claim Generator Info is always required with at least one entry.
    public var claimGeneratorInfo: [ClaimGeneratorInfo]

    /// The version of the claim. Defaults to 1.
    public var claimVersion: UInt8

    /// The format of the source file as a MIME type.
    public var format: String

    /// A list of ingredients.
    public var ingredients: [Ingredient]

    /// Instance ID from xmpMM:InstanceID in XMP metadata.
    public var instanceId: String?

    /// Allows you to pre-define the manifest label, which must be unique. Not intended for general use. If not set, it will be assigned automatically.
    public var label: String?

    /// Optional manifest metadata. This will be deprecated in the future; not recommended to use.
    @available(*, deprecated, message: "This will be deprecated in the future; not recommended to use.")
    public var metadata: [Metadata]?

    /// A list of redactions - URIs to redacted assertions.
    public var redactions: [String]?

    /// An optional ``ResourceRef`` to a thumbnail image that represents the asset that was signed. Must be available when the manifest is signed.
    public var thumbnail: ResourceRef?

    /// A human-readable title, generally source filename.
    public var title: String

    /// Optional prefix added to the generated Manifest Label This is typically a reverse domain name.
    public var vendor: String?


    /// - Parameters:
    ///   - assertions: A list of assertions.
    ///   - claimGeneratorInfo: Claim Generator Info is always required with at least one entry.
    ///   - claimVersion: The version of the claim. Defaults to 1.
    ///   - format: The format of the source file as a MIME type.
    ///   - ingredients: A list of ingredients.
    ///   - instanceId: Instance ID from xmpMM:InstanceID in XMP metadata.
    ///   - label: Allows you to pre-define the manifest label, which must be unique. Not intended for general use. If not set, it will be assigned automatically.
    ///   - redactions: A list of redactions - URIs to redacted assertions.
    ///   - thumbnail: An optional ``ResourceRef`` to a thumbnail image that represents the asset that was signed. Must be available when the manifest is signed.
    ///   - title: A human-readable title, generally source filename.
    ///   - vendor: Optional prefix added to the generated Manifest Label. This is typically a reverse domain name.
    public init(
        assertions: [AssertionDefinition] = [],
        claimGeneratorInfo: [ClaimGeneratorInfo],
        claimVersion: UInt8 = 1,
        format: String = "application/octet-stream",
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
        self.ingredients = ingredients
        self.instanceId = instanceId
        self.label = label
        self.redactions = redactions
        self.thumbnail = thumbnail
        self.title = title
        self.vendor = vendor
    }


    // MARK: CustomStringConvertible

    public var description: String {
        do {
            let data = try Self.jsonEncoder.encode(self)

            return String(data: data, encoding: .utf8) ?? "<ERROR encoding: Could not convert to UTF-8>"
        } catch {
            return "<ERROR encoding: \(error.localizedDescription)>"
        }
    }
}
