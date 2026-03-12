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

public final class C2PAJsonTests: TestImplementation {

    public init() {}

    public func testEncodeDecodeRoundTrip() -> TestResult {
        let manifest = ManifestDefinition(
            claimGeneratorInfo: [ClaimGeneratorInfo(name: "test")],
            title: "round-trip.jpg"
        )
        do {
            let json = try C2PAJson.encode(manifest)
            let decoded = try C2PAJson.decode(ManifestDefinition.self, from: json)
            guard decoded.title == "round-trip.jpg" else {
                return .failure("Round Trip", "Title mismatch after round-trip")
            }
            return .success("Round Trip", "[PASS] Encode/decode round-trip works")
        } catch {
            return .failure("Round Trip", "Error: \(error)")
        }
    }

    public func testEncodePretty() -> TestResult {
        let manifest = ManifestDefinition(
            claimGeneratorInfo: [ClaimGeneratorInfo(name: "test")],
            title: "pretty.jpg"
        )
        do {
            let json = try C2PAJson.encodePretty(manifest)
            guard json.contains("\n") else {
                return .failure("Pretty Encode", "Pretty JSON should contain newlines")
            }
            guard json.contains("pretty.jpg") else {
                return .failure("Pretty Encode", "Pretty JSON should contain title")
            }
            return .success("Pretty Encode", "[PASS] Pretty encoding produces formatted output")
        } catch {
            return .failure("Pretty Encode", "Error: \(error)")
        }
    }

    public func testDecodeFromString() -> TestResult {
        // Generate valid JSON via round-trip to match this branch's ManifestDefinition schema
        let original = ManifestDefinition(
            claimGeneratorInfo: [ClaimGeneratorInfo(name: "test")],
            title: "test.jpg"
        )
        do {
            let json = try C2PAJson.encode(original)
            let decoded = try C2PAJson.decode(ManifestDefinition.self, from: json)
            guard decoded.title == "test.jpg" else {
                return .failure("Decode String", "Title mismatch")
            }
            return .success("Decode String", "[PASS] Decode from string works")
        } catch {
            return .failure("Decode String", "Error: \(error)")
        }
    }

    public func testDecodeFromData() -> TestResult {
        let original = ManifestDefinition(
            claimGeneratorInfo: [ClaimGeneratorInfo(name: "test")],
            title: "data.jpg"
        )
        do {
            let json = try C2PAJson.encode(original)
            guard let data = json.data(using: .utf8) else {
                return .failure("Decode Data", "Could not create data from string")
            }
            let decoded = try C2PAJson.decode(ManifestDefinition.self, from: data)
            guard decoded.title == "data.jpg" else {
                return .failure("Decode Data", "Title mismatch")
            }
            return .success("Decode Data", "[PASS] Decode from data works")
        } catch {
            return .failure("Decode Data", "Error: \(error)")
        }
    }

    public func testDecodeInvalidJSON() -> TestResult {
        do {
            _ = try C2PAJson.decode(ManifestDefinition.self, from: "not valid json {{{")
            return .failure("Invalid JSON", "Should have thrown an error")
        } catch {
            return .success("Invalid JSON", "[PASS] Invalid JSON throws error: \(error)")
        }
    }

    public func runAllTests() async -> [TestResult] {
        return [
            testEncodeDecodeRoundTrip(),
            testEncodePretty(),
            testDecodeFromString(),
            testDecodeFromData(),
            testDecodeInvalidJSON()
        ]
    }
}
