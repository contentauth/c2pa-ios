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

// Test result structure for UI display
public struct TestResult: Sendable {
    public let testName: String
    public let passed: Bool
    public let message: String
    public let details: String?
    public let duration: TimeInterval?

    public init(testName: String, passed: Bool, message: String, details: String? = nil, duration: TimeInterval? = nil)
    {
        self.testName = testName
        self.passed = passed
        self.message = message
        self.details = details
        self.duration = duration
    }

    // Create a success result
    public static func success(_ testName: String, _ message: String, details: String? = nil)
        -> TestResult
    {
        TestResult(testName: testName, passed: true, message: message, details: details)
    }

    // Create a failure result
    public static func failure(_ testName: String, _ message: String, details: String? = nil)
        -> TestResult
    {
        TestResult(testName: testName, passed: false, message: message, details: details)
    }
}

// Protocol for test implementations
public protocol TestImplementation {
    func runAllTests() async -> [TestResult]
}
