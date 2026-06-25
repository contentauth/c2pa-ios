// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import Foundation
import TestShared

// Test runner for UI - aggregates all test suites
public final class TestRunner: Sendable {

    public init() {}

    // Run all test suites and return results
    public func runAllTests() async -> [TestSuiteResult] {
        var suites: [TestSuiteResult] = []

        for suite in TestSuite.allCases {
            let results = await runTestSuite(suite)
            suites.append(TestSuiteResult(name: suite.displayName, results: results))
        }

        return suites
    }

    // Run a specific test suite
    public func runTestSuite(_ suite: TestSuite) async -> [TestResult] {
        switch suite {
        case .stream:
            return await StreamTests().runAllTests()
        case .builder:
            return await BuilderTests().runAllTests()
        case .reader:
            return await ReaderTests().runAllTests()
        case .signing:
            return await SigningTests().runAllTests()
        case .signerExtended:
            return await SignerExtendedTests().runAllTests()
        case .certificateManager:
            return await CertificateManagerTests().runAllTests()
        case .hardwareSigning:
            return await HardwareSigningTests().runAllTests()
        case .secureEnclave:
            return await SecureEnclaveSignerTests().runAllTests()
        case .keychainSigner:
            return await KeychainSignerTests().runAllTests()
        case .webServiceSigner:
            return await WebServiceSignerTests().runAllTests()
        case .comprehensive:
            return await ComprehensiveTests().runAllTests()
        case .manifest:
            return await ManifestTests().runAllTests()
        case .assertionDefinition:
            return await AssertionDefinitionTests().runAllTests()
        case .settingsDefinition:
            return await SettingsDefinitionTests().runAllTests()
        case .context:
            return await ContextTests().runAllTests()
        case .convenience:
            return await ConvenienceTests().runAllTests()
        }
    }
}

// Available test suites
public enum TestSuite: String, CaseIterable, Sendable {
    case stream = "Stream"
    case builder = "Builder"
    case reader = "Reader"
    case signing = "Signing"
    case signerExtended = "Signer Extended"
    case certificateManager = "Certificate Manager"
    case hardwareSigning = "Hardware Signing"
    case secureEnclave = "Secure Enclave"
    case keychainSigner = "Keychain Signer"
    case webServiceSigner = "Web Service Signer"
    case comprehensive = "Comprehensive"
    case manifest = "Manifest"
    case assertionDefinition = "Assertion Definition"
    case settingsDefinition = "Settings Definition"
    case context = "Context"
    case convenience = "Convenience"

    public var displayName: String {
        return rawValue + " Tests"
    }
}

// Test suite result container
public struct TestSuiteResult: Sendable {
    public let name: String
    public let results: [TestResult]

    public init(name: String, results: [TestResult]) {
        self.name = name
        self.results = results
    }

    public var passedCount: Int {
        results.filter { $0.passed }.count
    }

    public var skippedCount: Int {
        results.filter { $0.skipped }.count
    }

    public var failedCount: Int {
        results.filter { !$0.passed && !$0.skipped }.count
    }

    public var totalCount: Int {
        results.count
    }

    public var passRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(passedCount) / Double(totalCount)
    }
}
