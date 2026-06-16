// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import SwiftUI
@preconcurrency import TestShared

struct TestResultsView: View {
    @State private var testSuites: [TestSuiteResult] = []
    @State private var isRunning = false
    @State private var selectedSuite: TestSuite?

    private let testRunner = TestRunner()

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: runAllTests) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Run All Tests")
                            Spacer()
                            if isRunning {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isRunning)
                }

                ForEach(testSuites, id: \.name) { suite in
                    Section(header: Text(suite.name)) {
                        HStack {
                            Text("Results")
                            Spacer()
                            if suite.skippedCount > 0 {
                                Text("\(suite.passedCount) passed, \(suite.skippedCount) skipped")
                                    .foregroundColor(suite.failedCount == 0 ? .green : .orange)
                            } else {
                                Text("\(suite.passedCount)/\(suite.totalCount)")
                                    .foregroundColor(suite.failedCount == 0 ? .green : .orange)
                            }
                        }

                        ForEach(suite.results, id: \.testName) { result in
                            TestResultRowView(result: result)
                        }
                    }
                }

                if testSuites.isEmpty {
                    Section(header: Text("Available Test Suites")) {
                        ForEach(TestSuite.allCases, id: \.self) { suite in
                            Button(
                                action: { runTestSuite(suite) },
                                label: {
                                    HStack {
                                        Image(systemName: "chevron.right.circle")
                                        Text(suite.displayName)
                                    }
                                })
                        }
                    }
                }
            }
            .navigationTitle("C2PA Tests")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Clear") {
                        testSuites = []
                    }
                }
            }
        }
    }

    private func runAllTests() {
        isRunning = true
        testSuites = []
        Task {
            for suite in TestSuite.allCases {
                let results = await testRunner.runTestSuite(suite)
                let suiteResult = TestSuiteResult(name: suite.displayName, results: results)
                testSuites.append(suiteResult)
            }
            isRunning = false
        }
    }

    private func runTestSuite(_ suite: TestSuite) {
        isRunning = true
        let suiteName = suite.displayName
        Task {
            let results = await testRunner.runTestSuite(suite)
            let suiteResult = TestSuiteResult(name: suiteName, results: results)

            // Replace if exists, otherwise append
            if let index = testSuites.firstIndex(where: { $0.name == suiteName }) {
                testSuites[index] = suiteResult
            } else {
                testSuites.append(suiteResult)
            }
            isRunning = false
        }
    }
}

struct TestResultRowView: View {
    let result: TestResult
    @State private var showDetails = false

    private var statusIcon: String {
        if result.skipped {
            return "forward.circle.fill"
        } else if result.passed {
            return "checkmark.circle.fill"
        } else {
            return "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        if result.skipped {
            return .orange
        } else if result.passed {
            return .green
        } else {
            return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)

                Text(result.testName)
                    .font(.system(.body, design: .monospaced))

                Spacer()

                if result.details != nil {
                    Button(
                        action: { showDetails.toggle() },
                        label: {
                            Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                                .font(.caption)
                        })
                }
            }

            Text(result.message)
                .font(.caption)
                .foregroundColor(.secondary)

            if showDetails, let details = result.details {
                Text(details)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
            }

            if let duration = result.duration {
                Text(String(format: "%.3fs", duration))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct TestResultsView_Previews: PreviewProvider {
    static var previews: some View {
        TestResultsView()
    }
}
