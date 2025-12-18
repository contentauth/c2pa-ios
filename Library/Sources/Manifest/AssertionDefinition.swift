//
//  AssertionDefinition.swift
//  C2PA
//
//  Created by Benjamin Erhart on 06.10.25.
//

import Foundation

/**
 Defines an assertion that consists of a label that can be either a C2PA-defined assertion label or a custom label in reverse domain format.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def#assertiondefinition

 The standard C2PA assertions are currently available:
 https://spec.c2pa.org/specifications/specifications/2.2/specs/C2PA_Specification.html#_standard_c2pa_assertion_summary

 But only `actions` is actually implemented!

 */
public enum AssertionDefinition: Codable, Equatable {

    public enum CodingKeys: CodingKey {
        case label
        case data
    }

    /**
     https://opensource.contentauthenticity.org/docs/manifest/writing/assertions-actions#actions
     */
    case actions(actions: [Action])

    case assertionMetadata
    case assetRef
    case assetType
    case bmffBasedHash
    case certificateStatus
    case cloudData
    case collectionDataHash
    case dataHash
    case depthmap
    case embeddedData
    case fontInfo
    case generalBoxHash
    case ingredient
    case metadata
    case multiAssetHash
    case softBinding
    case thumbnailClaim
    case thumbnailIngredient
    case timeStamps


    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let label = try container.decode(StandardAssertionLabel.self, forKey: .label)

        switch label {
        case .actions:
            let actions = try container.decode([String: [Action]].self, forKey: .data)

            self = .actions(actions: actions["actions"] ?? [])

        case .assertionMetadata:
            self = .assertionMetadata

        case .assetRef:
            self = .assetRef

        case .assetType:
            self = .assetType

        case .bmffBasedHash:
            self = .bmffBasedHash

        case .certificateStatus:
            self = .certificateStatus

        case .cloudData:
            self = .cloudData

        case .collectionDataHash:
            self = .collectionDataHash

        case .dataHash:
            self = .dataHash

        case .depthmap:
            self = .depthmap

        case .embeddedData:
            self = .embeddedData

        case .fontInfo:
            self = .fontInfo

        case .generalBoxHash:
            self = .generalBoxHash

        case .ingredient:
            self = .ingredient

        case .metadata:
            self = .metadata

        case .multiAssetHash:
            self = .multiAssetHash

        case .softBinding:
            self = .softBinding

        case .thumbnailClaim:
            self = .thumbnailClaim

        case .thumbnailIngredient:
            self = .thumbnailIngredient

        case .timeStamps:
            self = .timeStamps
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .actions(let actions):
            try container.encode(StandardAssertionLabel.actions, forKey: .label)
            try container.encode(["actions": actions], forKey: .data)

        case .assertionMetadata:
            try container.encode(StandardAssertionLabel.assertionMetadata, forKey: .label)

        case .assetRef:
            try container.encode(StandardAssertionLabel.assetRef, forKey: .label)

        case .assetType:
            try container.encode(StandardAssertionLabel.assetType, forKey: .label)

        case .bmffBasedHash:
            try container.encode(StandardAssertionLabel.bmffBasedHash, forKey: .label)

        case .certificateStatus:
            try container.encode(StandardAssertionLabel.certificateStatus, forKey: .label)

        case .cloudData:
            try container.encode(StandardAssertionLabel.cloudData, forKey: .label)

        case .collectionDataHash:
            try container.encode(StandardAssertionLabel.collectionDataHash, forKey: .label)

        case .dataHash:
            try container.encode(StandardAssertionLabel.dataHash, forKey: .label)

        case .depthmap:
            try container.encode(StandardAssertionLabel.depthmap, forKey: .label)

        case .embeddedData:
            try container.encode(StandardAssertionLabel.embeddedData, forKey: .label)

        case .fontInfo:
            try container.encode(StandardAssertionLabel.fontInfo, forKey: .label)

        case .generalBoxHash:
            try container.encode(StandardAssertionLabel.generalBoxHash, forKey: .label)

        case .ingredient:
            try container.encode(StandardAssertionLabel.ingredient, forKey: .label)

        case .metadata:
            try container.encode(StandardAssertionLabel.metadata, forKey: .label)

        case .multiAssetHash:
            try container.encode(StandardAssertionLabel.multiAssetHash, forKey: .label)

        case .softBinding:
            try container.encode(StandardAssertionLabel.softBinding, forKey: .label)

        case .thumbnailClaim:
            try container.encode(StandardAssertionLabel.thumbnailClaim, forKey: .label)

        case .thumbnailIngredient:
            try container.encode(StandardAssertionLabel.thumbnailIngredient, forKey: .label)

        case .timeStamps:
            try container.encode(StandardAssertionLabel.timeStamps, forKey: .label)
        }
    }
}
