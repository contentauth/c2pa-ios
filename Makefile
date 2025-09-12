.PHONY: all clean library test-shared test-app example-app publish tests coverage help \
        run-test-app run-example-app signing-server-start signing-server-stop signing-server-status \
        tests-with-server workspace-build test-library lint signing-server-wait signing-server-verify \
        test-summary coverage-lcov ios-framework validate-version release-tests package-xcframework \
        package-swift update-package-swift create-release-tag

# Build configuration
CONFIGURATION := Release
SDK := iphoneos
# Default destination - can be overridden from command line
DESTINATION ?= platform=iOS Simulator,name=iPhone 16 Pro

# Default target
all: workspace-build

# Lint the codebase
lint:
	@echo "Running SwiftLint..."
	@swiftlint lint --strict
	@echo "Linting completed."


# Build the C2PA library framework
library:
	@echo "Building C2PA library framework..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme Library -configuration $(CONFIGURATION) -destination '$(DESTINATION)' build
	@echo "Library build completed."


# Build entire workspace
workspace-build: library test-shared
	@echo "Building entire workspace..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme TestApp -configuration $(CONFIGURATION) -destination '$(DESTINATION)' build
	@xcodebuild -workspace C2PA.xcworkspace -scheme ExampleApp -configuration $(CONFIGURATION) -destination '$(DESTINATION)' build
	@echo "Workspace build completed."

# Build TestShared framework
test-shared: library
	@echo "Building TestShared framework..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme TestShared -configuration $(CONFIGURATION) -destination '$(DESTINATION)' build
	@echo "TestShared build completed."

# Build TestApp
test-app: test-shared
	@echo "Building TestApp..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme TestApp -configuration $(CONFIGURATION) -destination '$(DESTINATION)' build
	@echo "TestApp build completed."

# Build ExampleApp
example-app: library
	@echo "Building ExampleApp..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme ExampleApp -configuration $(CONFIGURATION) -destination '$(DESTINATION)' build
	@echo "ExampleApp build completed."

# Run library tests only
test-library: library
	@echo "Running library unit tests..."
	@rm -rf TestResults.xcresult
	@xcodebuild test \
		-workspace C2PA.xcworkspace \
		-scheme Library \
		-destination '$(DESTINATION)' \
		-resultBundlePath TestResults.xcresult \
		-enableCodeCoverage YES
	@echo "Library tests completed."

# Run all tests including unit and UI tests
tests: test-app
	@echo "Running all tests..."
	@rm -rf TestResults.xcresult
	@xcodebuild test \
		-workspace C2PA.xcworkspace \
		-scheme TestApp \
		-destination '$(DESTINATION)' \
		-resultBundlePath TestResults.xcresult \
		-enableCodeCoverage YES

# Quick test run (alias for test-library)
test: test-library

# Generate code coverage report
coverage: library
	@echo "Running tests with coverage..."
	@rm -rf TestResults.xcresult
	@xcodebuild test \
		-workspace C2PA.xcworkspace \
		-scheme Library \
		-configuration Debug \
		-enableCodeCoverage YES \
		-destination '$(DESTINATION)' \
		-resultBundlePath TestResults.xcresult
	@echo "Coverage report generated."

# Run test app
run-test-app: test-app
	@echo "Running test app..."
	@xcrun simctl boot "iPhone 16 Pro" || true
	@xcrun simctl install "iPhone 16 Pro" "$(shell xcodebuild -workspace C2PA.xcworkspace -scheme TestApp -configuration Debug -showBuildSettings | grep -m 1 'BUILT_PRODUCTS_DIR' | cut -d '=' -f 2 | xargs)/TestApp.app"
	@xcrun simctl launch "iPhone 16 Pro" org.contentauth.TestApp

# Run example app
run-example-app: example-app
	@echo "Running example app..."
	@xcrun simctl boot "iPhone 16 Pro" || true
	@xcrun simctl install "iPhone 16 Pro" "$(shell xcodebuild -workspace C2PA.xcworkspace -scheme ExampleApp -configuration Debug -showBuildSettings | grep -m 1 'BUILT_PRODUCTS_DIR' | cut -d '=' -f 2 | xargs)/ExampleApp.app"
	@xcrun simctl launch "iPhone 16 Pro" org.contentauth.ExampleApp

# Archive library for distribution
publish: library
	@echo "Archiving library..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme Library -configuration Release archive
	@echo "Library archived. Ready for distribution."

# Build iOS Framework (alias for library with release configuration)
ios-framework:
	@echo "Building iOS framework..."
	@$(MAKE) library CONFIGURATION=Release
	@echo "iOS framework build completed."

# Validate version format (expects VERSION environment variable)
validate-version:
	@echo "Validating version format..."
	@if [ -z "$(VERSION)" ]; then \
		echo "::error::VERSION environment variable is required"; \
		exit 1; \
	fi
	@if ! echo "$(VERSION)" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$$' > /dev/null; then \
		echo "::error::Version must be in format vX.Y.Z (e.g., v1.0.0)"; \
		exit 1; \
	fi
	@echo "Version $(VERSION) is valid."

# Run release tests
release-tests:
	@echo "Running release tests..."
	@if [ -d "example" ]; then \
		cd example && xcodebuild test \
			-scheme C2PAExample \
			-destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' \
			| xcpretty --test --color || true; \
	else \
		echo "Example directory not found, running library tests instead"; \
		$(MAKE) test-library; \
	fi

# Package XCFramework for distribution
package-xcframework:
	@echo "Packaging XCFramework..."
	@if [ -d "output" ]; then \
		cd output && zip -r C2PAC.xcframework.zip C2PAC.xcframework; \
		echo "XCFramework packaged successfully"; \
	elif [ -d "Library/Frameworks/C2PAC.xcframework" ]; then \
		mkdir -p output; \
		cp -R Library/Frameworks/C2PAC.xcframework output/; \
		cd output && zip -r C2PAC.xcframework.zip C2PAC.xcframework; \
		echo "XCFramework packaged successfully"; \
	else \
		echo "::error::C2PAC.xcframework not found"; \
		exit 1; \
	fi

# Compute checksum for XCFramework
compute-checksum:
	@echo "Computing checksum for XCFramework..."
	@if [ -f "output/C2PAC.xcframework.zip" ]; then \
		cd output && swift package compute-checksum C2PAC.xcframework.zip; \
	else \
		echo "::error::C2PAC.xcframework.zip not found in output directory"; \
		exit 1; \
	fi

# Package Swift sources
package-swift:
	@echo "Packaging Swift sources..."
	@if [ -d "output/C2PA-iOS" ]; then \
		cd output && zip -r C2PA-Swift-Package.zip C2PA-iOS/; \
	elif [ -d "Library/Sources/C2PA" ]; then \
		mkdir -p output/C2PA-iOS/Sources; \
		cp -R Library/Sources/C2PA output/C2PA-iOS/Sources/; \
		cd output && zip -r C2PA-Swift-Package.zip C2PA-iOS/; \
	else \
		echo "Swift sources packaged (skipped - no sources found)"; \
	fi

# Update Package.swift for release (in-place update)
update-package-swift:
	@echo "Updating Package.swift for release..."
	@if [ -z "$(VERSION)" ]; then \
		echo "::error::VERSION environment variable is required"; \
		exit 1; \
	fi
	@if [ -z "$(CHECKSUM)" ]; then \
		echo "::error::CHECKSUM environment variable is required"; \
		exit 1; \
	fi
	@if [ -z "$(GITHUB_REPOSITORY)" ]; then \
		echo "::error::GITHUB_REPOSITORY environment variable is required"; \
		exit 1; \
	fi
	@if [ -f "Package.swift" ]; then \
		sed -i '' 's#https://github.com/[^/]*/[^/]*/releases/download/v[0-9.]\+/C2PAC.xcframework.zip#https://github.com/$(GITHUB_REPOSITORY)/releases/download/$(VERSION)/C2PAC.xcframework.zip#g' Package.swift; \
		sed -i '' 's#checksum: "[a-f0-9]\{64\}"#checksum: "$(CHECKSUM)"#g' Package.swift; \
		echo "Package.swift updated successfully for release $(VERSION)"; \
	else \
		echo "::error::Package.swift not found"; \
		exit 1; \
	fi

# Tests with signing server
tests-with-server: signing-server-start tests signing-server-stop
	@echo "Tests with server completed."

# Start the signing server (setup is handled by Xcode scheme)
signing-server-start:
	@echo "Building and starting signing server..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme SigningServer -configuration Debug build
	@cd SigningServer && SIGNING_SERVER_URL=http://localhost:8080 SIGNING_SERVER_TOKEN=test-bearer-token-12345 nohup swift run SigningServer > ../signing-server.log 2>&1 &
	@echo "Signing server started with PID $$!"
	@echo "Server running at http://localhost:8080 with bearer token authentication"

# Stop the signing server
signing-server-stop:
	@echo "Stopping signing server..."
	@pkill -f "SigningServer" || true
	@pkill -f ".build/debug/SigningServer" || true
	@echo "Server stopped."

# Check signing server status
signing-server-status:
	@echo "Checking signing server status..."
	@ps aux | grep -v grep | grep "SigningServer" || echo "Server is not running"

# Wait for signing server to be ready
signing-server-wait:
	@echo "Waiting for signing server to be ready..."
	@max_attempts=30; \
	attempt=0; \
	while [ $$attempt -lt $$max_attempts ]; do \
		if curl -s http://127.0.0.1:8080/health > /dev/null 2>&1; then \
			echo "✓ Signing server is ready"; \
			break; \
		fi; \
		echo "Waiting for server... (attempt $$((attempt + 1))/$$max_attempts)"; \
		sleep 2; \
		attempt=$$((attempt + 1)); \
	done; \
	if [ $$attempt -eq $$max_attempts ]; then \
		echo "❌ Server failed to start after $$max_attempts attempts"; \
		exit 1; \
	fi

# Verify signing server endpoints
signing-server-verify:
	@echo "Testing server endpoints..."
	@curl -v http://127.0.0.1:8080/health || echo "Health check failed"
	@echo ""
	@echo "Server is listening on:"
	@lsof -i :8080 || echo "No process on port 8080"

# Generate test summary from xcresult
test-summary:
	@echo "Generating test summary..."
	@if [ -d "TestResults.xcresult" ]; then \
		echo "=== Test Summary ==="; \
		xcrun xcresulttool get test-results summary --path TestResults.xcresult || true; \
		echo ""; \
		echo "=== Test Results ==="; \
		xcrun xcresulttool get test-results tests --path TestResults.xcresult || true; \
		echo ""; \
		echo "Test results available in TestResults.xcresult"; \
	else \
		echo "TestResults.xcresult not found"; \
		echo "Run 'make test-library' or 'make tests' first to generate test results"; \
	fi

# Export coverage to LCOV format
coverage-lcov:
	@echo "Exporting coverage to LCOV and JSON formats..."
	@if [ ! -d "TestResults.xcresult" ]; then \
		echo "ERROR: TestResults.xcresult not found. Run tests first with 'make test-library'"; \
		exit 1; \
	fi
	@echo "Finding coverage data in xcresult bundle..."
	@PROFDATA_PATH=$$(find TestResults.xcresult -name "*.profdata" -type f 2>/dev/null | head -1); \
	if [ -z "$$PROFDATA_PATH" ]; then \
		echo "Trying DerivedData for profdata..."; \
		DERIVED_DATA=$$(xcodebuild -workspace C2PA.xcworkspace -scheme Library -showBuildSettings | grep -m 1 'BUILT_PRODUCTS_DIR' | cut -d '=' -f 2 | xargs | sed 's|/Build/Products.*||'); \
		PROFDATA_PATH=$$(find "$$DERIVED_DATA" -path "*/Build/ProfileData/*/Coverage.profdata" -type f 2>/dev/null | head -1); \
	fi; \
	echo "Coverage.profdata path: $$PROFDATA_PATH"; \
	BINARY_PATH=$$(find TestResults.xcresult -path "*/Products/Debug-iphonesimulator/C2PA.framework/C2PA" -type f 2>/dev/null | head -1); \
	if [ -z "$$BINARY_PATH" ]; then \
		echo "Trying to find test binary..."; \
		BINARY_PATH=$$(find TestResults.xcresult -name "*.xctest" -type d 2>/dev/null | head -1); \
		if [ -n "$$BINARY_PATH" ]; then \
			BINARY_NAME=$$(basename "$$BINARY_PATH" .xctest); \
			BINARY_PATH="$$BINARY_PATH/$$BINARY_NAME"; \
		fi; \
	fi; \
	if [ -z "$$BINARY_PATH" ]; then \
		echo "Trying DerivedData for binary..."; \
		DERIVED_DATA=$$(xcodebuild -workspace C2PA.xcworkspace -scheme Library -showBuildSettings | grep -m 1 'BUILT_PRODUCTS_DIR' | cut -d '=' -f 2 | xargs | sed 's|/Build/Products.*||'); \
		BINARY_PATH=$$(find "$$DERIVED_DATA" -path "*/C2PATests.xctest/C2PATests" -o -path "*/LibraryTests.xctest/LibraryTests" -type f 2>/dev/null | head -1); \
	fi; \
	echo "Binary path: $$BINARY_PATH"; \
	if [ -n "$$PROFDATA_PATH" ] && [ -n "$$BINARY_PATH" ] && [ -f "$$PROFDATA_PATH" ] && [ -f "$$BINARY_PATH" ]; then \
		echo "Generating LCOV format..."; \
		xcrun llvm-cov export \
			-format=lcov \
			-instr-profile="$$PROFDATA_PATH" \
			"$$BINARY_PATH" \
			> coverage.lcov 2>/dev/null; \
		if [ -s "coverage.lcov" ]; then \
			echo "✓ LCOV coverage report generated ($$(wc -c < coverage.lcov) bytes)"; \
		else \
			echo "✗ LCOV generation failed"; \
		fi; \
		echo "Generating JSON format..."; \
		xcrun xccov view --report --json TestResults.xcresult > coverage.json 2>/dev/null || true; \
		if [ -s "coverage.json" ]; then \
			echo "✓ JSON coverage report generated ($$(wc -c < coverage.json) bytes)"; \
		fi; \
	else \
		echo "✗ Could not find profdata or binary, using xccov for JSON only..."; \
		xcrun xccov view --report --json TestResults.xcresult > coverage.json 2>/dev/null || true; \
		if [ -s "coverage.json" ]; then \
			echo "✓ JSON coverage report generated ($$(wc -c < coverage.json) bytes)"; \
		fi; \
	fi

# Clean test and coverage artifacts
clean-coverage:
	@echo "Cleaning test and coverage artifacts..."
	@rm -rf TestResults.xcresult
	@rm -f coverage.json coverage.lcov coverage.txt
	@rm -f coverage-*.lcov
	@rm -f signing-server.log
	@echo "Test artifacts cleaned."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@xcodebuild -workspace C2PA.xcworkspace -scheme Library clean
	@xcodebuild -workspace C2PA.xcworkspace -scheme TestShared clean
	@xcodebuild -workspace C2PA.xcworkspace -scheme TestApp clean
	@xcodebuild -workspace C2PA.xcworkspace -scheme ExampleApp clean
	@xcodebuild -workspace C2PA.xcworkspace -scheme SigningServer clean
	@rm -rf SigningServer/.build
	@rm -rf build
	@$(MAKE) clean-coverage
	@echo "Clean complete."

# Help target
help:
	@echo "Available targets:"
	@echo "  make              - Build the library (default)"
	@echo "  make lint         - Run SwiftLint on the codebase"
	@echo "  make library      - Build the C2PA library framework"
	@echo "  make ios-framework - Build iOS framework (release configuration)"
	@echo "  make test-shared  - Build the TestShared framework"
	@echo "  make test-app     - Build the TestApp"
	@echo "  make example-app  - Build the ExampleApp"
	@echo "  make workspace-build - Build entire workspace"
	@echo "  make test-library - Run library unit tests only"
	@echo "  make tests        - Run all tests"
	@echo "  make release-tests - Run tests for release validation"
	@echo "  make test-summary - Generate test summary from xcresult"
	@echo "  make coverage     - Generate test coverage report"
	@echo "  make coverage-lcov - Export coverage to LCOV format"
	@echo "  make run-test-app - Build and run the test app in simulator"
	@echo "  make run-example-app - Build and run the example app in simulator"
	@echo "  make publish      - Prepare library for publishing"
	@echo "  make validate-version - Validate version format (VERSION=vX.Y.Z)"
	@echo "  make package-xcframework - Package XCFramework for distribution"
	@echo "  make compute-checksum - Compute checksum for XCFramework"
	@echo "  make package-swift - Package Swift sources"
	@echo "  make update-package-swift - Update Package.swift for release"
	@echo "  make signing-server-start - Start the signing server"
	@echo "  make signing-server-stop  - Stop the signing server"
	@echo "  make signing-server-status - Check server status"
	@echo "  make signing-server-wait - Wait for server to be ready"
	@echo "  make signing-server-verify - Verify server endpoints"
	@echo "  make tests-with-server - Run tests with signing server"
	@echo "  make clean-coverage - Clean test and coverage artifacts"
	@echo "  make clean        - Clean all build artifacts"
	@echo "  make help         - Show this help message"
