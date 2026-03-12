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

public final class C2PAErrorTests: TestImplementation {

    public init() {}

    public func testAllErrorDescriptions() -> TestResult {
        var testSteps: [String] = []

        let cases: [(C2PAError, String)] = [
            (.api("test message"), "C2PA API error"),
            (.nilPointer, "NULL pointer"),
            (.utf8, "UTF-8"),
            (.negative(-42), "-42"),
            (.ingridientDataNotFound("original"), "ingredient data"),
            (.ed25519NotSupported, "Ed25519"),
            (.keySearchFailed("tag", -1, false), "keychain"),
            (.keySearchFailed("tag", -1, true), "Secure Enclave"),
            (.unsupportedAlgorithm(.es256, false), "algorithm"),
            (.unsupportedAlgorithm(.es256, true), "Secure Enclave"),
            (.signingFailed(nil, false), "Signing"),
            (.signingFailed(nil, true), "Secure Enclave"),
            (.accessControlCreationFailed, "access control"),
            (.keyCreationFailed(nil, false), "create"),
            (.keyCreationFailed(nil, true), "Secure Enclave"),
            (.publicKeyExtractionFailed, "extract"),
            (.publicKeyExportFailed(nil), "export"),
            (.asyncSigningFailed, "Async")
        ]

        for (error, expectedSubstring) in cases {
            guard let description = error.errorDescription else {
                return .failure("Error Descriptions", "errorDescription is nil for \(error)")
            }
            guard description.contains(expectedSubstring) else {
                return .failure("Error Descriptions", "\(error): expected '\(expectedSubstring)' in '\(description)'")
            }
            testSteps.append("\(error): contains '\(expectedSubstring)'")
        }

        // Test with non-nil upstream errors
        let nsError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "upstream"])
        let withError = C2PAError.signingFailed(nsError, false)
        guard let desc = withError.errorDescription, desc.contains("upstream") else {
            return .failure("Error Descriptions", "signingFailed with error should contain upstream message")
        }
        testSteps.append("signingFailed(error): contains upstream message")

        let keyError = C2PAError.keyCreationFailed(nsError, false)
        guard let keyDesc = keyError.errorDescription, keyDesc.contains("upstream") else {
            return .failure("Error Descriptions", "keyCreationFailed with error should contain upstream message")
        }
        testSteps.append("keyCreationFailed(error): contains upstream message")

        let exportError = C2PAError.publicKeyExportFailed(nsError)
        guard let exportDesc = exportError.errorDescription, exportDesc.contains("upstream") else {
            return .failure("Error Descriptions", "publicKeyExportFailed with error should contain upstream message")
        }
        testSteps.append("publicKeyExportFailed(error): contains upstream message")

        return .success("Error Descriptions", testSteps.joined(separator: "\n"))
    }

    public func runAllTests() async -> [TestResult] {
        return [
            testAllErrorDescriptions()
        ]
    }
}
