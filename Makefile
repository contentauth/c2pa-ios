.PHONY: all clean setup download-binaries ios-framework

# GitHub Release Configuration
GITHUB_ORG := contentauth
C2PA_VERSION := v0.59.0

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

	# Copy Swift wrapper and patch c2pa.h
	@cp $(APPLE_DIR)/src/C2PA.swift $(1)/Sources/C2PA/
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

# Helper to show available targets
help:
	@echo "Available targets:"
	@echo "  setup                 - Create necessary directories"
	@echo "  download-binaries     - Download pre-built binaries from GitHub releases"
	@echo "  ios-dev               - Build iOS library for arm64 simulator only (optimized for Apple Silicon)"
	@echo "  ios-framework         - Create iOS XCFramework"
	@echo "  all                   - Build iOS framework (default)"
	@echo "  clean                 - Remove build artifacts"
	@echo "  help                  - Show this help message"
