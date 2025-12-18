//
//  ManifestDefinition.swift
//  C2PA
//
//  Created by Benjamin Erhart on 06.10.25.
//

import Foundation

/**
 Modelled after https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def
 */
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


    /**
     A list of assertions.
     */
    public var assertions: [AssertionDefinition]

    /**
     Claim Generator Info is always required with at least one entry.
     */
    public var claimGeneratorInfo: [ClaimGeneratorInfo]

    /**
     The version of the claim. Defaults to 1.
     */
    public var claimVersion: UInt8

    /**
     The format of the source file as a MIME type.
     */
    public var format: String

    /**
     A list of ingredients.
     */
    public var ingredients: [Ingredient]

    /**
     Instance ID from xmpMM:InstanceID in XMP metadata.
     */
    public var instanceId: String?

    /**
     Allows you to pre-define the manifest label, which must be unique. Not intended for general use. If not set, it will be assigned automatically.
     */
    public var label: String?

    /**
     Optional manifest metadata. This will be deprecated in the future; not recommended to use.
     */
    @available(*, deprecated, message: "This will be deprecated in the future; not recommended to use.")
    public var metadata: [Metadata]?

    /**
     A list of redactions - URIs to redacted assertions.
     */
    public var redactions: [String]?

    /**
     An optional ``ResourceRef`` to a thumbnail image that represents the asset that was signed. Must be available when the manifest is signed.
     */
    public var thumbnail: ResourceRef?

    /**
     A human-readable title, generally source filename.
     */
    public var title: String

    /**
     Optional prefix added to the generated Manifest Label This is typically a reverse domain name.
     */
    public var vendor: String?


    /**
     - parameter assertions: A list of assertions.
     - parameter claimGeneratorInfo: Claim Generator Info is always required with at least one entry.
     - parameter claimVersion: The version of the claim. Defaults to 1.
     - parameter format: The format of the source file as a MIME type.
     - parameter ingredients: A list of ingredients.
     - parameter instanceId: Instance ID from xmpMM:InstanceID in XMP metadata.
     - parameter label: Allows you to pre-define the manifest label, which must be unique. Not intended for general use. If not set, it will be assigned automatically.
     - parameter redactions: A list of redactions - URIs to redacted assertions.
     - parameter thumbnail: An optional ``ResourceRef`` to a thumbnail image that represents the asset that was signed. Must be available when the manifest is signed.
     - parameter title: A human-readable title, generally source filename.
     - parameter vendor: Optional prefix added to the generated Manifest Label This is typically a reverse domain name.
     */
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
