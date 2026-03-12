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
//  AssertionDefinition.swift
//

import Foundation

/// Defines an assertion in a C2PA manifest.
///
/// An assertion consists of a label identifying its type and associated data.
/// Labels can be standard C2PA labels, CAWG labels, or custom reverse-domain labels.
///
/// ## Standard Assertions
///
/// The most commonly used assertions are:
/// - ``actions(actions:)`` -- describes operations performed on the content
/// - ``creativeWork(data:)`` -- Schema.org CreativeWork metadata
/// - ``trainingMining(entries:)`` -- C2PA training/mining permissions
/// - ``cawgIdentity(data:)`` -- CAWG identity assertion (must be in gathered assertions)
///
/// ## Custom Assertions
///
/// Use ``custom(label:data:)`` for assertions not covered by the standard types.
/// Custom labels must use reverse-domain format (e.g., `com.example.myassertion`).
///
/// - SeeAlso: [AssertionDefinition Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema#assertiondefinition)
/// - SeeAlso: ``StandardAssertionLabel``
public enum AssertionDefinition: Codable, Equatable {
    public enum CodingKeys: CodingKey {
        case label
        case data
    }

    // MARK: - Cases

    /// An actions assertion describing operations on the content.
    ///
    /// - SeeAlso: [Actions Reference](https://opensource.contentauthenticity.org/docs/manifest/writing/assertions-actions#actions)
    case actions(actions: [Action])

    /// A Schema.org CreativeWork metadata assertion.
    case creativeWork(data: [String: AnyCodable])

    /// A C2PA training/mining permission assertion.
    case trainingMining(entries: [TrainingMiningEntry])

    /// A CAWG identity assertion.
    ///
    /// - Important: This assertion must be placed in `gatheredAssertions`, not `assertions`.
    case cawgIdentity(data: [String: AnyCodable])

    /// A CAWG AI training and data mining assertion.
    case cawgTrainingMining(entries: [CawgTrainingMiningEntry])

    /// A custom assertion with a user-defined label.
    ///
    /// - Parameters:
    ///   - label: The assertion label in reverse-domain format.
    ///   - data: The assertion data.
    case custom(label: String, data: AnyCodable)

    // MARK: - Standard C2PA Assertions (data-less)

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

    // MARK: - Base Label

    /// The base label string for this assertion.
    public var baseLabel: String {
        switch self {
        case .actions: return StandardAssertionLabel.actions.rawValue
        case .creativeWork: return StandardAssertionLabel.creativeWork.rawValue
        case .trainingMining: return StandardAssertionLabel.trainingMining.rawValue
        case .cawgIdentity: return StandardAssertionLabel.cawgIdentity.rawValue
        case .cawgTrainingMining: return StandardAssertionLabel.cawgAITraining.rawValue
        case .custom(let label, _): return label
        case .assertionMetadata: return StandardAssertionLabel.assertionMetadata.rawValue
        case .assetRef: return StandardAssertionLabel.assetRef.rawValue
        case .assetType: return StandardAssertionLabel.assetType.rawValue
        case .bmffBasedHash: return StandardAssertionLabel.bmffBasedHash.rawValue
        case .certificateStatus: return StandardAssertionLabel.certificateStatus.rawValue
        case .cloudData: return StandardAssertionLabel.cloudData.rawValue
        case .collectionDataHash: return StandardAssertionLabel.collectionDataHash.rawValue
        case .dataHash: return StandardAssertionLabel.dataHash.rawValue
        case .depthmap: return StandardAssertionLabel.depthmap.rawValue
        case .embeddedData: return StandardAssertionLabel.embeddedData.rawValue
        case .fontInfo: return StandardAssertionLabel.fontInfo.rawValue
        case .generalBoxHash: return StandardAssertionLabel.generalBoxHash.rawValue
        case .ingredient: return StandardAssertionLabel.ingredient.rawValue
        case .metadata: return StandardAssertionLabel.metadata.rawValue
        case .multiAssetHash: return StandardAssertionLabel.multiAssetHash.rawValue
        case .softBinding: return StandardAssertionLabel.softBinding.rawValue
        case .thumbnailClaim: return StandardAssertionLabel.thumbnailClaim.rawValue
        case .thumbnailIngredient: return StandardAssertionLabel.thumbnailIngredient.rawValue
        case .timeStamps: return StandardAssertionLabel.timeStamps.rawValue
        }
    }

    // MARK: - Codable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let labelString = try container.decode(String.self, forKey: .label)

        guard let standardLabel = StandardAssertionLabel(rawValue: labelString) else {
            // Custom assertion with unknown label
            let data = try container.decode(AnyCodable.self, forKey: .data)
            self = .custom(label: labelString, data: data)
            return
        }

        switch standardLabel {
        case .actions, .actionsV2:
            let actions = try container.decode([String: [Action]].self, forKey: .data)
            self = .actions(actions: actions["actions"] ?? [])
        case .creativeWork:
            let data = try container.decode([String: AnyCodable].self, forKey: .data)
            self = .creativeWork(data: data)
        case .trainingMining:
            let data = try container.decode([String: [TrainingMiningEntry]].self, forKey: .data)
            self = .trainingMining(entries: data["entries"] ?? [])
        case .cawgIdentity:
            let data = try container.decode([String: AnyCodable].self, forKey: .data)
            self = .cawgIdentity(data: data)
        case .cawgAITraining:
            let data = try container.decode([String: [CawgTrainingMiningEntry]].self, forKey: .data)
            self = .cawgTrainingMining(entries: data["entries"] ?? [])
        case .assertionMetadata: self = .assertionMetadata
        case .assetRef: self = .assetRef
        case .assetType: self = .assetType
        case .bmffBasedHash: self = .bmffBasedHash
        case .certificateStatus: self = .certificateStatus
        case .cloudData: self = .cloudData
        case .collectionDataHash: self = .collectionDataHash
        case .dataHash: self = .dataHash
        case .depthmap: self = .depthmap
        case .embeddedData: self = .embeddedData
        case .fontInfo: self = .fontInfo
        case .generalBoxHash: self = .generalBoxHash
        case .ingredient, .ingredientV3: self = .ingredient
        case .metadata: self = .metadata
        case .multiAssetHash: self = .multiAssetHash
        case .softBinding: self = .softBinding
        case .thumbnailClaim: self = .thumbnailClaim
        case .thumbnailIngredient: self = .thumbnailIngredient
        case .timeStamps: self = .timeStamps
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .actions(let actions):
            try container.encode(StandardAssertionLabel.actions.rawValue, forKey: .label)
            try container.encode(["actions": actions], forKey: .data)
        case .creativeWork(let data):
            try container.encode(StandardAssertionLabel.creativeWork.rawValue, forKey: .label)
            try container.encode(data, forKey: .data)
        case .trainingMining(let entries):
            try container.encode(StandardAssertionLabel.trainingMining.rawValue, forKey: .label)
            try container.encode(["entries": entries], forKey: .data)
        case .cawgIdentity(let data):
            try container.encode(StandardAssertionLabel.cawgIdentity.rawValue, forKey: .label)
            try container.encode(data, forKey: .data)
        case .cawgTrainingMining(let entries):
            try container.encode(StandardAssertionLabel.cawgAITraining.rawValue, forKey: .label)
            try container.encode(["entries": entries], forKey: .data)
        case .custom(let label, let data):
            try container.encode(label, forKey: .label)
            try container.encode(data, forKey: .data)
        case .assertionMetadata:
            try container.encode(StandardAssertionLabel.assertionMetadata.rawValue, forKey: .label)
        case .assetRef:
            try container.encode(StandardAssertionLabel.assetRef.rawValue, forKey: .label)
        case .assetType:
            try container.encode(StandardAssertionLabel.assetType.rawValue, forKey: .label)
        case .bmffBasedHash:
            try container.encode(StandardAssertionLabel.bmffBasedHash.rawValue, forKey: .label)
        case .certificateStatus:
            try container.encode(StandardAssertionLabel.certificateStatus.rawValue, forKey: .label)
        case .cloudData:
            try container.encode(StandardAssertionLabel.cloudData.rawValue, forKey: .label)
        case .collectionDataHash:
            try container.encode(StandardAssertionLabel.collectionDataHash.rawValue, forKey: .label)
        case .dataHash:
            try container.encode(StandardAssertionLabel.dataHash.rawValue, forKey: .label)
        case .depthmap:
            try container.encode(StandardAssertionLabel.depthmap.rawValue, forKey: .label)
        case .embeddedData:
            try container.encode(StandardAssertionLabel.embeddedData.rawValue, forKey: .label)
        case .fontInfo:
            try container.encode(StandardAssertionLabel.fontInfo.rawValue, forKey: .label)
        case .generalBoxHash:
            try container.encode(StandardAssertionLabel.generalBoxHash.rawValue, forKey: .label)
        case .ingredient:
            try container.encode(StandardAssertionLabel.ingredient.rawValue, forKey: .label)
        case .metadata:
            try container.encode(StandardAssertionLabel.metadata.rawValue, forKey: .label)
        case .multiAssetHash:
            try container.encode(StandardAssertionLabel.multiAssetHash.rawValue, forKey: .label)
        case .softBinding:
            try container.encode(StandardAssertionLabel.softBinding.rawValue, forKey: .label)
        case .thumbnailClaim:
            try container.encode(StandardAssertionLabel.thumbnailClaim.rawValue, forKey: .label)
        case .thumbnailIngredient:
            try container.encode(StandardAssertionLabel.thumbnailIngredient.rawValue, forKey: .label)
        case .timeStamps:
            try container.encode(StandardAssertionLabel.timeStamps.rawValue, forKey: .label)
        }
    }
}

// MARK: - Supporting Types

/// An entry in a C2PA training/mining assertion.
public struct TrainingMiningEntry: Codable, Equatable, Sendable {
    /// The permitted use (e.g., "notAllowed", "constrained", "allowed").
    public let use: String

    /// Additional constraint information when use is "constrained".
    public let constraintInfo: String?

    public enum CodingKeys: String, CodingKey {
        case use
        case constraintInfo = "constraint_info"
    }

    public init(use: String, constraintInfo: String? = nil) {
        self.use = use
        self.constraintInfo = constraintInfo
    }
}

/// An entry in a CAWG AI training and data mining assertion.
public struct CawgTrainingMiningEntry: Codable, Equatable, Sendable {
    /// The permitted use.
    public let use: String

    /// Additional constraint information.
    public let constraintInfo: String?

    /// The AI model learning type.
    public let aiModelLearningType: String?

    /// The AI mining type.
    public let aiMiningType: String?

    public enum CodingKeys: String, CodingKey {
        case use
        case constraintInfo = "constraint_info"
        case aiModelLearningType = "ai_model_learning_type"
        case aiMiningType = "ai_mining_type"
    }

    public init(
        use: String,
        constraintInfo: String? = nil,
        aiModelLearningType: String? = nil,
        aiMiningType: String? = nil
    ) {
        self.use = use
        self.constraintInfo = constraintInfo
        self.aiModelLearningType = aiModelLearningType
        self.aiMiningType = aiMiningType
    }
}

/// A type-erased Codable value for dynamic JSON data.
///
/// Used in assertion types that carry unstructured JSON payloads
/// (creative work metadata, CAWG identity data, custom assertions).
public struct AnyCodable: Codable, Equatable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported value type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported value type"))
        }
    }

    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // Compare serialized JSON for equality
        guard let lhsData = try? JSONEncoder().encode(lhs),
              let rhsData = try? JSONEncoder().encode(rhs) else {
            return false
        }
        return lhsData == rhsData
    }
}
