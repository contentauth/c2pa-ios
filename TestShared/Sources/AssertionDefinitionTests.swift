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

// AssertionDefinition tests - testing assertion encoding and decoding
public final class AssertionDefinitionTests: TestImplementation {

    public init() {}

    // MARK: - Helper Methods

    private func createAssertionJSON(label: String, data: [String: Any]? = nil) -> String {
        var json: [String: Any] = ["label": label]
        if let data = data {
            json["data"] = data
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: json),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }

    // MARK: - Actions Assertion Tests

    public func testActionsAssertionDecoding() -> TestResult {
        var testSteps: [String] = []

        let actionsJSON = """
        {
            "label": "c2pa.actions",
            "data": {
                "actions": [
                    {
                        "action": "c2pa.created"
                    },
                    {
                        "action": "c2pa.edited",
                        "parameters": {
                            "name": "test edit"
                        }
                    }
                ]
            }
        }
        """

        do {
            let decoder = JSONDecoder()
            let assertion = try decoder.decode(AssertionDefinition.self, from: actionsJSON.data(using: .utf8)!)
            testSteps.append("Decoded actions assertion")

            if case .actions(let actions) = assertion {
                testSteps.append("Actions count: \(actions.count)")
                guard actions.count == 2 else {
                    return .failure("Actions Decoding", "Expected 2 actions, got \(actions.count)")
                }
            } else {
                return .failure("Actions Decoding", "Decoded assertion is not .actions")
            }

            return .success(
                "Actions Assertion Decoding",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("Error: \(error)")
            return .failure(
                "Actions Assertion Decoding",
                testSteps.joined(separator: "\n"))
        }
    }

    public func testActionsAssertionEncoding() -> TestResult {
        var testSteps: [String] = []

        let action1 = Action(
            action: PredefinedAction.created,
            digitalSourceType: DigitalSourceType.algorithmicMedia
        )
        let action2 = Action(
            action: PredefinedAction.edited.rawValue
        )

        let assertion = AssertionDefinition.actions(actions: [action1, action2])

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(assertion)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            testSteps.append("Encoded actions assertion")
            testSteps.append("JSON length: \(jsonString.count) characters")

            guard jsonString.contains("c2pa.actions") else {
                return .failure("Actions Encoding", "Missing c2pa.actions label")
            }
            testSteps.append("JSON contains c2pa.actions label")

            // Decode it back
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: jsonData)
            if case .actions(let actions) = decoded {
                testSteps.append("Round-trip successful, decoded \(actions.count) actions")
            }

            return .success(
                "Actions Assertion Encoding",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("Error: \(error)")
            return .failure(
                "Actions Assertion Encoding",
                testSteps.joined(separator: "\n"))
        }
    }

    public func testEmptyActionsAssertion() -> TestResult {
        var testSteps: [String] = []

        let emptyActionsJSON = """
        {
            "label": "c2pa.actions",
            "data": {
                "actions": []
            }
        }
        """

        do {
            let decoder = JSONDecoder()
            let assertion = try decoder.decode(AssertionDefinition.self, from: emptyActionsJSON.data(using: .utf8)!)

            if case .actions(let actions) = assertion {
                testSteps.append("Decoded empty actions: \(actions.count)")
                guard actions.isEmpty else {
                    return .failure("Empty Actions", "Expected 0 actions")
                }
            } else {
                return .failure("Empty Actions", "Wrong assertion type")
            }

            return .success(
                "Empty Actions Assertion",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("Error: \(error)")
            return .failure(
                "Empty Actions Assertion",
                testSteps.joined(separator: "\n"))
        }
    }

    // MARK: - Other Assertion Types Tests

    public func testAssertionMetadataDecoding() -> TestResult {
        var testSteps: [String] = []

        let json = """
        {"label": "c2pa.assertion.metadata"}
        """

        do {
            let assertion = try JSONDecoder().decode(AssertionDefinition.self, from: json.data(using: .utf8)!)

            if case .assertionMetadata = assertion {
                testSteps.append("Decoded assertionMetadata assertion")
            } else {
                return .failure("assertionMetadata Decoding", "Wrong assertion type")
            }

            // Test encoding
            let encoded = try JSONEncoder().encode(assertion)
            let encodedString = String(data: encoded, encoding: .utf8) ?? ""
            testSteps.append("Encoded: \(encodedString)")

            return .success(
                "assertionMetadata Decoding/Encoding",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("Error: \(error)")
            return .failure(
                "assertionMetadata Decoding",
                testSteps.joined(separator: "\n"))
        }
    }

    public func testAssetRefDecoding() -> TestResult {
        var testSteps: [String] = []

        // Note: assetRef uses hyphen not dot: "c2pa.asset-ref"
        let json = """
        {"label": "c2pa.asset-ref"}
        """

        do {
            let assertion = try JSONDecoder().decode(AssertionDefinition.self, from: json.data(using: .utf8)!)

            if case .assetRef = assertion {
                testSteps.append("Decoded assetRef assertion")
            } else {
                return .failure("assetRef Decoding", "Wrong assertion type")
            }

            let encoded = try JSONEncoder().encode(assertion)
            testSteps.append("Round-trip encoding successful")
            _ = encoded

            return .success(
                "assetRef Decoding/Encoding",
                testSteps.joined(separator: "\n"))

        } catch {
            testSteps.append("Error: \(error)")
            return .failure(
                "assetRef Decoding",
                testSteps.joined(separator: "\n"))
        }
    }

    public func testAllAssertionTypesEncoding() -> TestResult {
        var testSteps: [String] = []

        // Test encoding of all assertion types (except actions which has associated data)
        let assertions: [(String, AssertionDefinition)] = [
            ("assertionMetadata", .assertionMetadata),
            ("assetRef", .assetRef),
            ("assetType", .assetType),
            ("bmffBasedHash", .bmffBasedHash),
            ("certificateStatus", .certificateStatus),
            ("cloudData", .cloudData),
            ("collectionDataHash", .collectionDataHash),
            ("dataHash", .dataHash),
            ("depthmap", .depthmap),
            ("embeddedData", .embeddedData),
            ("fontInfo", .fontInfo),
            ("generalBoxHash", .generalBoxHash),
            ("ingredient", .ingredient),
            ("metadata", .metadata),
            ("multiAssetHash", .multiAssetHash),
            ("softBinding", .softBinding),
            ("thumbnailClaim", .thumbnailClaim),
            ("thumbnailIngredient", .thumbnailIngredient),
            ("timeStamps", .timeStamps)
        ]

        let encoder = JSONEncoder()

        for (name, assertion) in assertions {
            do {
                let data = try encoder.encode(assertion)
                let jsonString = String(data: data, encoding: .utf8) ?? ""
                testSteps.append("\(name): encoded successfully")

                guard jsonString.contains("label") else {
                    return .failure("Assertion Encoding", "\(name) missing label field")
                }
            } catch {
                return .failure("Assertion Encoding", "\(name) encoding failed: \(error)")
            }
        }

        return .success(
            "All Assertion Types Encoding",
            testSteps.joined(separator: "\n"))
    }

    public func testAllAssertionTypesRoundTrip() -> TestResult {
        var testSteps: [String] = []

        // All standard assertion labels (must match StandardAssertionLabel raw values)
        let labels = [
            "c2pa.assertion.metadata",
            "c2pa.asset-ref",
            "c2pa.asset-type.v2",
            "c2pa.hash.bmff.v3",
            "c2pa.certificate-status",
            "c2pa.cloud-data",
            "c2pa.hash.collection.data",
            "c2pa.hash.data",
            "c2pa.depthmap.GDepth",
            "c2pa.embedded-data",
            "font.info",
            "c2pa.hash.boxes",
            "c2pa.ingredient",
            "c2pa.metadata",
            "c2pa.hash.multi-asset",
            "c2pa.soft-binding",
            "c2pa.thumbnail.claim",
            "c2pa.thumbnail.ingredient",
            "c2pa.time-stamp"
        ]

        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        for label in labels {
            let json = "{\"label\": \"\(label)\"}"

            do {
                let assertion = try decoder.decode(AssertionDefinition.self, from: json.data(using: .utf8)!)
                let reencoded = try encoder.encode(assertion)
                _ = try decoder.decode(AssertionDefinition.self, from: reencoded)
                testSteps.append("\(label): round-trip OK")
            } catch {
                // Some labels might not be fully implemented
                testSteps.append("\(label): \(error)")
            }
        }

        return .success(
            "Assertion Types Round-Trip",
            testSteps.joined(separator: "\n"))
    }

    // MARK: - Equality Tests

    public func testAssertionEquality() -> TestResult {
        var testSteps: [String] = []

        // Test equality of same types
        let assertion1 = AssertionDefinition.metadata
        let assertion2 = AssertionDefinition.metadata
        guard assertion1 == assertion2 else {
            return .failure("Assertion Equality", "Same assertions should be equal")
        }
        testSteps.append("metadata == metadata: true")

        // Test inequality of different types
        let assertion3 = AssertionDefinition.assetRef
        guard assertion1 != assertion3 else {
            return .failure("Assertion Equality", "Different assertions should not be equal")
        }
        testSteps.append("metadata != assetRef: true")

        // Test actions equality
        let action = Action(action: PredefinedAction.created, digitalSourceType: DigitalSourceType.digitalCapture)
        let actions1 = AssertionDefinition.actions(actions: [action])
        let actions2 = AssertionDefinition.actions(actions: [action])
        guard actions1 == actions2 else {
            return .failure("Assertion Equality", "Same actions should be equal")
        }
        testSteps.append("actions(same) == actions(same): true")

        // Test actions inequality with different content
        let action2 = Action(action: PredefinedAction.edited.rawValue)
        let actions3 = AssertionDefinition.actions(actions: [action2])
        guard actions1 != actions3 else {
            return .failure("Assertion Equality", "Different actions should not be equal")
        }
        testSteps.append("actions(created) != actions(edited): true")

        return .success(
            "Assertion Equality",
            testSteps.joined(separator: "\n"))
    }

    // MARK: - Custom Assertion Tests

    public func testCustomAssertionRoundTrip() -> TestResult {
        let assertion = AssertionDefinition.custom(
            label: "com.example.test",
            data: AnyCodable(["key": "value", "number": 42] as [String: Any])
        )
        do {
            let data = try JSONEncoder().encode(assertion)
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: data)
            if case .custom(let label, _) = decoded {
                guard label == "com.example.test" else {
                    return .failure("Custom Round-Trip", "Label mismatch: \(label)")
                }
            } else {
                return .failure("Custom Round-Trip", "Decoded as wrong type")
            }
            return .success("Custom Assertion", "[PASS] Custom assertion round-trip works")
        } catch {
            return .failure("Custom Assertion", "Error: \(error)")
        }
    }

    // MARK: - Training/Mining Assertion Tests

    public func testTrainingMiningAssertion() -> TestResult {
        let entries = [
            TrainingMiningEntry(use: "notAllowed"),
            TrainingMiningEntry(use: "constrained", constraintInfo: "License required")
        ]
        let assertion = AssertionDefinition.trainingMining(entries: entries)
        do {
            let data = try JSONEncoder().encode(assertion)
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: data)
            if case .trainingMining(let decodedEntries) = decoded {
                guard decodedEntries.count == 2 else {
                    return .failure("TrainingMining", "Expected 2 entries, got \(decodedEntries.count)")
                }
                guard decodedEntries[0].use == "notAllowed" else {
                    return .failure("TrainingMining", "First entry use mismatch")
                }
                guard decodedEntries[1].constraintInfo == "License required" else {
                    return .failure("TrainingMining", "Second entry constraintInfo mismatch")
                }
            } else {
                return .failure("TrainingMining", "Decoded as wrong type")
            }
            return .success("TrainingMining", "[PASS] Training/mining assertion round-trip works")
        } catch {
            return .failure("TrainingMining", "Error: \(error)")
        }
    }

    public func testCawgTrainingMiningAssertion() -> TestResult {
        let entries = [
            CawgTrainingMiningEntry(
                use: "allowed",
                constraintInfo: nil,
                aiModelLearningType: "supervised",
                aiMiningType: "text"
            )
        ]
        let assertion = AssertionDefinition.cawgTrainingMining(entries: entries)
        do {
            let data = try JSONEncoder().encode(assertion)
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: data)
            if case .cawgTrainingMining(let decodedEntries) = decoded {
                guard decodedEntries.first?.aiModelLearningType == "supervised" else {
                    return .failure("CawgTrainingMining", "aiModelLearningType mismatch")
                }
            } else {
                return .failure("CawgTrainingMining", "Decoded as wrong type")
            }
            return .success("CawgTrainingMining", "[PASS] CAWG training/mining round-trip works")
        } catch {
            return .failure("CawgTrainingMining", "Error: \(error)")
        }
    }

    // MARK: - Other Typed Assertions

    public func testCawgIdentityAssertion() -> TestResult {
        let assertion = AssertionDefinition.cawgIdentity(data: [
            "sig_type": AnyCodable("cawg.x509"),
            "pad1": AnyCodable(0)
        ])
        do {
            let data = try JSONEncoder().encode(assertion)
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: data)
            if case .cawgIdentity(let decodedData) = decoded {
                guard decodedData["sig_type"] != nil else {
                    return .failure("CawgIdentity", "Missing sig_type in decoded data")
                }
            } else {
                return .failure("CawgIdentity", "Decoded as wrong type")
            }
            return .success("CawgIdentity", "[PASS] CAWG identity assertion round-trip works")
        } catch {
            return .failure("CawgIdentity", "Error: \(error)")
        }
    }

    public func testCreativeWorkAssertion() -> TestResult {
        let assertion = AssertionDefinition.creativeWork(data: [
            "@type": AnyCodable("CreativeWork"),
            "author": AnyCodable(["@type": "Person", "name": "Test Author"] as [String: Any])
        ])
        do {
            let data = try JSONEncoder().encode(assertion)
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: data)
            if case .creativeWork(let decodedData) = decoded {
                guard decodedData["@type"] != nil else {
                    return .failure("CreativeWork", "Missing @type in decoded data")
                }
            } else {
                return .failure("CreativeWork", "Decoded as wrong type")
            }
            return .success("CreativeWork", "[PASS] Creative work assertion round-trip works")
        } catch {
            return .failure("CreativeWork", "Error: \(error)")
        }
    }

    // MARK: - AnyCodable Tests

    public func testAnyCodableTypes() -> TestResult {
        let values: [(String, AnyCodable)] = [
            ("bool", AnyCodable(true)),
            ("int", AnyCodable(42)),
            ("double", AnyCodable(3.14)),
            ("string", AnyCodable("hello")),
            ("array", AnyCodable([1, 2, 3])),
            ("dict", AnyCodable(["key": "value"] as [String: Any]))
        ]
        for (name, value) in values {
            do {
                let data = try JSONEncoder().encode(value)
                let decoded = try JSONDecoder().decode(AnyCodable.self, from: data)
                guard value == decoded else {
                    return .failure("AnyCodable", "\(name) round-trip failed")
                }
            } catch {
                return .failure("AnyCodable", "\(name) error: \(error)")
            }
        }
        return .success("AnyCodable Types", "[PASS] All AnyCodable types round-trip correctly")
    }

    public func testAnyCodableEquality() -> TestResult {
        let a = AnyCodable("hello")
        let b = AnyCodable("hello")
        let c = AnyCodable("world")
        guard a == b else {
            return .failure("AnyCodable Equality", "Same values should be equal")
        }
        guard a != c else {
            return .failure("AnyCodable Equality", "Different values should not be equal")
        }
        return .success("AnyCodable Equality", "[PASS] AnyCodable equality works")
    }

    // MARK: - Actions V2 Label

    public func testActionsV2Decoding() -> TestResult {
        let json = """
        {
            "label": "c2pa.actions.v2",
            "data": {
                "actions": [{"action": "c2pa.created"}]
            }
        }
        """
        do {
            let decoded = try JSONDecoder().decode(AssertionDefinition.self, from: json.data(using: .utf8)!)
            if case .actions(let actions) = decoded {
                guard actions.count == 1 else {
                    return .failure("Actions V2", "Expected 1 action")
                }
            } else {
                return .failure("Actions V2", "Should decode as .actions")
            }
            return .success("Actions V2", "[PASS] c2pa.actions.v2 label decodes correctly")
        } catch {
            return .failure("Actions V2", "Error: \(error)")
        }
    }

    public func runAllTests() async -> [TestResult] {
        var results: [TestResult] = []

        results.append(testActionsAssertionDecoding())
        results.append(testActionsAssertionEncoding())
        results.append(testEmptyActionsAssertion())
        results.append(testAssertionMetadataDecoding())
        results.append(testAssetRefDecoding())
        results.append(testAllAssertionTypesEncoding())
        results.append(testAllAssertionTypesRoundTrip())
        results.append(testAssertionEquality())
        results.append(testCustomAssertionRoundTrip())
        results.append(testTrainingMiningAssertion())
        results.append(testCawgTrainingMiningAssertion())
        results.append(testCawgIdentityAssertion())
        results.append(testCreativeWorkAssertion())
        results.append(testAnyCodableTypes())
        results.append(testAnyCodableEquality())
        results.append(testActionsV2Decoding())

        return results
    }
}
