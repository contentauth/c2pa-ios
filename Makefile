.PHONY: all clean setup download-binaries ios-framework setup-server server clean-server

# GitHub Release Configuration
GITHUB_ORG := contentauth
C2PA_VERSION := v0.64.0

# Directories
ROOT_DIR := $(shell pwd)
BUILD_DIR := $(ROOT_DIR)/build
DOWNLOAD_DIR := $(BUILD_DIR)/downloads
APPLE_DIR := $(ROOT_DIR)
OUTPUT_DIR := $(ROOT_DIR)/output

# Apple targets
IOS_FRAMEWORK_NAME := C2PAC
IOS_XCFRAMEWORK_PATH := $(OUTPUT_DIR)/$(IOS_FRAMEWORK_NAME).xcframework

# iOS architectures
IOS_ARCHS := arm64 x86_64 arm64-simulator
IOS_ARM64_TARGET := aarch64-apple-ios
IOS_X86_64_TARGET := x86_64-apple-ios
IOS_ARM64_SIM_TARGET := aarch64-apple-ios-sim

# Default target
all: ios-framework

# Setup directories
setup:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(DOWNLOAD_DIR)
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(BUILD_DIR)/ios/arm64/lib
	@mkdir -p $(BUILD_DIR)/ios/x86_64/lib
	@mkdir -p $(BUILD_DIR)/ios/arm64-simulator/lib
	@mkdir -p $(BUILD_DIR)/patched_headers

# Function to download and extract a pre-built library
# Args: 1=architecture name for display, 2=release filename suffix, 3=target directory name
define download_library
	@echo "Downloading iOS $(1) library..."
	@curl -sL https://github.com/$(GITHUB_ORG)/c2pa-rs/releases/download/c2pa-$(C2PA_VERSION)/c2pa-$(C2PA_VERSION)-$(2).zip -o $(DOWNLOAD_DIR)/$(3).zip
	@unzip -q -o $(DOWNLOAD_DIR)/$(3).zip -d $(DOWNLOAD_DIR)/$(3)
	@cp $(DOWNLOAD_DIR)/$(3)/lib/libc2pa_c.a $(BUILD_DIR)/ios/$(3)/lib/
	$(if $(4),@cp $(DOWNLOAD_DIR)/$(3)/include/c2pa.h $(BUILD_DIR)/patched_headers/c2pa.h.orig)
endef

# Download pre-built binaries from GitHub releases
download-binaries: setup
	@echo "Downloading pre-built binaries from $(GITHUB_ORG)/c2pa-rs release c2pa-$(C2PA_VERSION)..."
	
	# Download all iOS libraries
	$(call download_library,arm64,aarch64-apple-ios,arm64,true)
	$(call download_library,x86_64 simulator,x86_64-apple-ios,x86_64)
	$(call download_library,arm64 simulator,aarch64-apple-ios-sim,arm64-simulator)
	
	# Patch the header file
	@echo "Patching c2pa.h header..."
	@sed 's/typedef struct C2paSigner C2paSigner;/typedef struct C2paSigner { } C2paSigner;/g' $(BUILD_DIR)/patched_headers/c2pa.h.orig > $(BUILD_DIR)/patched_headers/c2pa.h
	@rm -f $(BUILD_DIR)/patched_headers/c2pa.h.orig
	
	@echo "Pre-built binaries downloaded successfully."

ios-framework: download-binaries
	@echo "Creating XCFramework..."
	@mkdir -p $(OUTPUT_DIR)

	# Create device library
	@mkdir -p $(BUILD_DIR)/ios/device/lib
	@cp $(BUILD_DIR)/ios/arm64/lib/libc2pa_c.a $(BUILD_DIR)/ios/device/lib/

	# Create simulator fat library
	@mkdir -p $(BUILD_DIR)/ios/simulator/lib
	@lipo -create \
		$(BUILD_DIR)/ios/x86_64/lib/libc2pa_c.a \
		$(BUILD_DIR)/ios/arm64-simulator/lib/libc2pa_c.a \
		-output $(BUILD_DIR)/ios/simulator/lib/libc2pa_c.a

	# First, make sure the output directory doesn't exist (to avoid conflicts)
	@rm -rf $(IOS_XCFRAMEWORK_PATH)

	# Create XCFramework and Swift package
	$(call create_xcframework,$(IOS_XCFRAMEWORK_PATH),$(BUILD_DIR)/ios/device/lib/libc2pa_c.a,$(BUILD_DIR)/ios/simulator/lib/libc2pa_c.a)

	# Clear the output package directory to avoid conflicts
	@rm -rf $(OUTPUT_DIR)/C2PA-iOS
	$(call setup_swift_package,$(OUTPUT_DIR)/C2PA-iOS,$(IOS_XCFRAMEWORK_PATH))

	@echo "XCFramework created at $(IOS_XCFRAMEWORK_PATH)"
	@echo "Swift package ready at $(OUTPUT_DIR)/C2PA-iOS"

# Function to create an XCFramework with device and simulator libraries
# Args: 1=output path, 2=device lib path, 3=simulator lib path
define create_xcframework
	@xcodebuild -create-xcframework \
		-library $(2) \
		-headers $(BUILD_DIR)/patched_headers \
		-library $(3) \
		-headers $(BUILD_DIR)/patched_headers \
		-output $(1)

	@echo "Copying module.modulemap and ensuring patched c2pa.h is in XCFramework headers..."
	@find $(1) -type d -path "*/Headers" | while read headers_dir; do \
		cp $(APPLE_DIR)/template/module.modulemap "$$headers_dir/"; \
		cp $(BUILD_DIR)/patched_headers/c2pa.h "$$headers_dir/"; \
	done
endef

# Function to create and setup Swift package
# Args: 1=output dir, 2=xcframework source path
define setup_swift_package
	@mkdir -p $(1)/Sources/C2PA
	@mkdir -p $(1)/Frameworks

	# Copy Swift wrapper files
	@cp $(APPLE_DIR)/src/C2PA.swift $(1)/Sources/C2PA/
	@cp $(APPLE_DIR)/src/CertificateManager.swift $(1)/Sources/C2PA/
	@cp $(APPLE_DIR)/template/Package.swift $(1)/

	# Copy XCFramework
	@cp -r $(2) $(1)/Frameworks/

	@echo "Swift package ready at $(1)"
endef

# iOS simulator-only quick build - optimized for Apple Silicon Macs (arm64 only)
ios-dev: setup download-binaries
	@echo "Building for iOS arm64 simulator only (optimized for Apple Silicon)..."
	@rm -rf $(IOS_XCFRAMEWORK_PATH)
	$(call create_xcframework,$(IOS_XCFRAMEWORK_PATH),$(BUILD_DIR)/ios/arm64-simulator/lib/libc2pa_c.a,$(BUILD_DIR)/ios/arm64-simulator/lib/libc2pa_c.a)
	@rm -rf $(OUTPUT_DIR)/C2PA-iOS
	$(call setup_swift_package,$(OUTPUT_DIR)/C2PA-iOS,$(IOS_XCFRAMEWORK_PATH))
	@echo "iOS simulator-only XCFramework built at $(IOS_XCFRAMEWORK_PATH)"

# Clean target
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(OUTPUT_DIR)
	@echo "Clean completed."

# Function to download and extract macOS library for server
# Args: 1=architecture name for display, 2=release filename suffix, 3=target directory name
define download_macos_library
	@echo "Downloading macOS $(1) library..."
	@mkdir -p $(DOWNLOAD_DIR)
	@curl -sL https://github.com/$(GITHUB_ORG)/c2pa-rs/releases/download/c2pa-$(C2PA_VERSION)/c2pa-$(C2PA_VERSION)-$(2).zip -o $(DOWNLOAD_DIR)/$(3).zip
	@unzip -q -o $(DOWNLOAD_DIR)/$(3).zip -d $(DOWNLOAD_DIR)/$(3)
endef

# Server targets
setup-server:
	@echo "Setting up C2PA signing server..."
	@command -v swift >/dev/null 2>&1 || { echo "Error: Swift is required but not installed."; exit 1; }
	
	# Create server directories
	@mkdir -p signing-server/libs
	@mkdir -p signing-server/Sources/C2PA/include
	@mkdir -p signing-server/Resources
	
	# Download universal macOS binary
	$(call download_macos_library,universal,universal-apple-darwin,macos-universal)
	
	# Copy dylib to server
	@cp $(DOWNLOAD_DIR)/macos-universal/lib/libc2pa_c.dylib signing-server/libs/
	
	# Get header file from macOS download
	@cp $(DOWNLOAD_DIR)/macos-universal/include/c2pa.h signing-server/Sources/C2PA/include/c2pa.h.orig
	
	# Patch the header file
	@echo "Patching c2pa.h header for server..."
	@sed 's/typedef struct C2paSigner C2paSigner;/typedef struct C2paSigner { } C2paSigner;/g' signing-server/Sources/C2PA/include/c2pa.h.orig > signing-server/Sources/C2PA/include/c2pa.h
	@rm -f signing-server/Sources/C2PA/include/c2pa.h.orig
	
	# Copy Swift files and module map
	@cp src/C2PA.swift signing-server/Sources/C2PA/
	@cp src/CertificateManager.swift signing-server/Sources/C2PA/
	@cp template/module.modulemap signing-server/Sources/C2PA/
	# Update header path in module map for server structure
	@sed -i '' 's|header "c2pa.h"|header "include/c2pa.h"|' signing-server/Sources/C2PA/module.modulemap
	
	# Copy test certificates
	@cp example/C2PAExample/es256_certs.pem signing-server/Resources/
	@cp example/C2PAExample/es256_private.key signing-server/Resources/
	
	@cd signing-server && swift package resolve
	@echo "Server setup complete!"

server: setup-server
	@echo "Building server..."
	@cd signing-server && swift build
	@echo "Starting C2PA signing server in development mode..."
	@cd signing-server && DYLD_LIBRARY_PATH=libs:$$DYLD_LIBRARY_PATH .build/debug/Run serve --env development --hostname 127.0.0.1 --port 8080

clean-server:
	@echo "Cleaning server build artifacts and copied files..."
	@cd signing-server && swift package clean
	@cd signing-server && rm -rf .build
	@rm -rf signing-server/libs
	@rm -rf signing-server/Sources/C2PA
	@rm -rf signing-server/Resources
	@echo "Server clean completed."

# Helper to show available targets
help:
	@echo "Available targets:"
	@echo ""
	@echo "iOS Framework:"
	@echo "  setup                 - Create necessary directories"
	@echo "  download-binaries     - Download pre-built binaries from GitHub releases"
	@echo "  ios-dev               - Build iOS library for arm64 simulator only (optimized for Apple Silicon)"
	@echo "  ios-framework         - Create iOS XCFramework"
	@echo "  all                   - Build iOS framework (default)"
	@echo "  clean                 - Remove build artifacts"
	@echo ""
	@echo "Test Server:"
	@echo "  setup-server          - Set up the C2PA signing server (downloads libs, copies files)"
	@echo "  server                - Build and run the signing server (port 8080)"
	@echo "  clean-server          - Clean server build artifacts"
	@echo ""
	@echo "  help                  - Show this help message"
