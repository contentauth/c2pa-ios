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

        // Stream Tests
        let streamTests = StreamTests()
        let streamResults = await streamTests.runAllTests()
        suites.append(TestSuiteResult(name: "Stream Tests", results: streamResults))

        // Builder Tests
        let builderTests = BuilderTests()
        let builderResults = await builderTests.runAllTests()
        suites.append(TestSuiteResult(name: "Builder Tests", results: builderResults))

        // Reader Tests
        let readerTests = ReaderTests()
        let readerResults = await readerTests.runAllTests()
        suites.append(TestSuiteResult(name: "Reader Tests", results: readerResults))

        // Signing Tests
        let signingTests = SigningTests()
        let signingResults = await signingTests.runAllTests()
        suites.append(TestSuiteResult(name: "Signing Tests", results: signingResults))

        // Hardware Signing Tests
        let hardwareSigningTests = HardwareSigningTests()
        let hardwareSigningResults = await hardwareSigningTests.runAllTests()
        suites.append(TestSuiteResult(name: "Hardware Signing Tests", results: hardwareSigningResults))

        // Comprehensive Tests
        let comprehensiveTests = ComprehensiveTests()
        let comprehensiveResults = await comprehensiveTests.runAllTests()
        suites.append(TestSuiteResult(name: "Comprehensive Tests", results: comprehensiveResults))

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
        case .hardwareSigning:
            return await HardwareSigningTests().runAllTests()
        case .comprehensive:
            return await ComprehensiveTests().runAllTests()
        }
    }
}

// Available test suites
public enum TestSuite: String, CaseIterable {
    case stream = "Stream"
    case builder = "Builder"
    case reader = "Reader"
    case signing = "Signing"
    case hardwareSigning = "Hardware Signing"
    case comprehensive = "Comprehensive"

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

    public var failedCount: Int {
        results.filter { !$0.passed }.count
    }

    public var totalCount: Int {
        results.count
    }

    public var passRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(passedCount) / Double(totalCount)
    }
}
