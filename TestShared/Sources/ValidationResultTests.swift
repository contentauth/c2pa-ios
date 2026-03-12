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

public final class ValidationResultTests: TestImplementation {

    public init() {}

    public func testValidResult() -> TestResult {
        let result = ValidationResult.valid
        guard result.isValid else {
            return .failure("Valid Result", "ValidationResult.valid should be valid")
        }
        guard !result.hasErrors else {
            return .failure("Valid Result", "ValidationResult.valid should have no errors")
        }
        guard !result.hasWarnings else {
            return .failure("Valid Result", "ValidationResult.valid should have no warnings")
        }
        return .success("Valid Result", "[PASS] ValidationResult.valid is valid with no errors/warnings")
    }

    public func testResultWithErrors() -> TestResult {
        let result = ValidationResult(errors: ["error1", "error2"])
        guard !result.isValid else {
            return .failure("With Errors", "Result with errors should not be valid")
        }
        guard result.hasErrors else {
            return .failure("With Errors", "hasErrors should be true")
        }
        guard !result.hasWarnings else {
            return .failure("With Errors", "hasWarnings should be false when no warnings")
        }
        guard result.errors.count == 2 else {
            return .failure("With Errors", "Expected 2 errors")
        }
        return .success("With Errors", "[PASS] Result with errors is invalid")
    }

    public func testResultWithWarnings() -> TestResult {
        let result = ValidationResult(warnings: ["warning1"])
        guard result.isValid else {
            return .failure("With Warnings", "Result with only warnings should still be valid")
        }
        guard !result.hasErrors else {
            return .failure("With Warnings", "hasErrors should be false")
        }
        guard result.hasWarnings else {
            return .failure("With Warnings", "hasWarnings should be true")
        }
        return .success("With Warnings", "[PASS] Result with warnings only is still valid")
    }

    public func testResultWithBoth() -> TestResult {
        let result = ValidationResult(errors: ["error"], warnings: ["warning"])
        guard !result.isValid else {
            return .failure("With Both", "Result with errors should not be valid")
        }
        guard result.hasErrors else {
            return .failure("With Both", "hasErrors should be true")
        }
        guard result.hasWarnings else {
            return .failure("With Both", "hasWarnings should be true")
        }
        return .success("With Both", "[PASS] Result with both errors and warnings is invalid")
    }

    public func testEmptyInit() -> TestResult {
        let result = ValidationResult()
        guard result.isValid else {
            return .failure("Empty Init", "Default init should be valid")
        }
        guard result.errors.isEmpty else {
            return .failure("Empty Init", "Default init should have empty errors")
        }
        guard result.warnings.isEmpty else {
            return .failure("Empty Init", "Default init should have empty warnings")
        }
        return .success("Empty Init", "[PASS] Default init produces valid result")
    }

    public func runAllTests() async -> [TestResult] {
        return [
            testValidResult(),
            testResultWithErrors(),
            testResultWithWarnings(),
            testResultWithBoth(),
            testEmptyInit()
        ]
    }
}
