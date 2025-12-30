# =============================================================================
# Nexus Flight Software Makefile
# =============================================================================

# Project configuration
PROJECT_NAME := nexus-fsw
DOCKER_IMAGE := $(PROJECT_NAME)-toolchain
DOCKER_TAG := latest
DOCKER_FULL := $(DOCKER_IMAGE):$(DOCKER_TAG)

# Directories
BUILD_DIR := build
BUILD_RELEASE_DIR := build-release
BUILD_TEST_DIR := build-test
DOCKER_DIR := docker

# Build configuration
CMAKE_PRESET_DEBUG := debug
CMAKE_PRESET_RELEASE := release
CMAKE_PRESET_TEST := host-test

# Detect OS and convert path for Docker on Windows
ifeq ($(OS),Windows_NT)
    # Convert Git Bash path (e.g., /d/nexus) to Windows path (e.g., D:/nexus)
    WORKSPACE_PATH := $(shell cygpath -m "$(CURDIR)")
else
    WORKSPACE_PATH := $(CURDIR)
endif

# Docker run command - mounts current directory
# Use //workspace to prevent MSYS path conversion in Git Bash
DOCKER_RUN := docker run --rm -v "$(WORKSPACE_PATH):/workspace" -w //workspace $(DOCKER_FULL)

# UniFlash configuration
UNIFLASH_DIR := C:/ti/uniflash_9.4.0
UNIFLASH := $(UNIFLASH_DIR)/dslite.bat
CCXML_FILE := bsp/tms570lc43/TMS570LC43xx.ccxml
FIRMWARE := $(BUILD_DIR)/app/$(PROJECT_NAME).out

# Serial port (adjust as needed)
SERIAL_PORT := COM6
BAUD_RATE := 115200

.PHONY: help
help: ## Show this help message
	@echo "Nexus Flight Software - Makefile Targets"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""

# =============================================================================
# Docker Toolchain Management
# =============================================================================

.PHONY: toolchain-build
toolchain-build: ## Build the Docker toolchain image
	@echo "Building Docker toolchain image..."
	docker build -t $(DOCKER_FULL) -f $(DOCKER_DIR)/Dockerfile .
	@echo "Toolchain image built successfully!"

.PHONY: toolchain-rebuild
toolchain-rebuild: ## Rebuild the Docker toolchain image (no cache)
	@echo "Rebuilding Docker toolchain image (no cache)..."
	docker build --no-cache -t $(DOCKER_FULL) -f $(DOCKER_DIR)/Dockerfile .
	@echo "Toolchain image rebuilt successfully!"

.PHONY: toolchain-shell
toolchain-shell: ## Start an interactive shell in the toolchain container
	@echo "Starting toolchain shell..."
	docker run --rm -it -v "$(WORKSPACE_PATH):/workspace" -w //workspace $(DOCKER_FULL) bash

.PHONY: toolchain-info
toolchain-info: ## Show toolchain version information
	@echo "Toolchain Information:"
	@echo ""
	@echo "TI ARM Compiler:"
	@$(DOCKER_RUN) armcl 2>&1 | head -3
	@echo ""
	@echo "CMake:"
	@$(DOCKER_RUN) cmake --version | head -1
	@echo ""
	@echo "Ninja:"
	@$(DOCKER_RUN) ninja --version

# =============================================================================
# Build Targets
# =============================================================================

.PHONY: configure
configure: ## Configure CMake for debug build
	@echo "Configuring CMake (debug)..."
	@$(DOCKER_RUN) cmake --preset $(CMAKE_PRESET_DEBUG)
	@ln -sf $(BUILD_DIR)/compile_commands.json compile_commands.json
	@echo "Configuration complete!"

.PHONY: configure-release
configure-release: ## Configure CMake for release build
	@echo "Configuring CMake (release)..."
	@$(DOCKER_RUN) cmake --preset $(CMAKE_PRESET_RELEASE)
	@echo "Configuration complete!"

.PHONY: configure-test
configure-test: ## Configure CMake for host tests
	@echo "Configuring CMake (host tests)..."
	@$(DOCKER_RUN) cmake --preset $(CMAKE_PRESET_TEST)
	@echo "Configuration complete!"

.PHONY: build
build: ## Build debug firmware (default target)
	@echo "Building firmware (debug)..."
	@$(DOCKER_RUN) cmake --build $(BUILD_DIR)
	@echo "Build complete! Firmware: $(BUILD_DIR)/app/$(PROJECT_NAME).out"

.PHONY: release
release: ## Build release firmware
	@echo "Building firmware (release)..."
	@$(DOCKER_RUN) cmake --build $(BUILD_RELEASE_DIR)
	@echo "Build complete! Firmware: $(BUILD_RELEASE_DIR)/app/$(PROJECT_NAME).out"

.PHONY: rebuild
rebuild: clean configure build ## Clean and rebuild debug firmware

.PHONY: all
all: configure build ## Configure and build (debug)

# =============================================================================
# Flashing Targets (Windows UniFlash)
# =============================================================================

.PHONY: flash
flash: ## Flash firmware to target using UniFlash (Windows)
	@echo "Flashing firmware to TMS570LC4357..."
	@if [ ! -f "$(FIRMWARE)" ]; then \
		echo "Error: Firmware not found at $(FIRMWARE)"; \
		echo "Run 'make build' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(CCXML_FILE)" ]; then \
		echo "Error: CCXML file not found at $(CCXML_FILE)"; \
		exit 1; \
	fi
	"$(UNIFLASH)" -c "$(CCXML_FILE)" -f "$(FIRMWARE)" -v
	@echo "Flashing complete!"

.PHONY: flash-release
flash-release: ## Flash release firmware to target
	@echo "Flashing release firmware to TMS570LC4357..."
	"$(UNIFLASH)" -c "$(CCXML_FILE)" -f "$(BUILD_RELEASE_DIR)/app/$(PROJECT_NAME).out" -v
	@echo "Flashing complete!"

.PHONY: erase
erase: ## Erase target flash memory
	@echo "Erasing flash memory..."
	"$(UNIFLASH)" -c "$(CCXML_FILE)" -e
	@echo "Erase complete!"

# =============================================================================
# Serial Monitor
# =============================================================================

.PHONY: monitor
monitor: ## Open serial monitor (Windows, requires putty or similar)
	@echo "Opening serial monitor on $(SERIAL_PORT)..."
	@echo "Using PuTTY (install if needed: winget install PuTTY.PuTTY)"
	putty -serial $(SERIAL_PORT) -sercfg $(BAUD_RATE),8,n,1,N

# =============================================================================
# Cleaning
# =============================================================================

.PHONY: clean
clean: ## Clean debug build artifacts
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f compile_commands.json
	@echo "Clean complete!"

.PHONY: clean-release
clean-release: ## Clean release build artifacts
	@echo "Cleaning release build artifacts..."
	@rm -rf $(BUILD_RELEASE_DIR)
	@echo "Clean complete!"

.PHONY: clean-test
clean-test: ## Clean test build artifacts
	@echo "Cleaning test build artifacts..."
	@rm -rf $(BUILD_TEST_DIR)
	@echo "Clean complete!"

.PHONY: clean-all
clean-all: clean clean-release clean-test ## Clean all build artifacts
	@echo "All build artifacts cleaned!"

# =============================================================================
# Code Quality
# =============================================================================

.PHONY: format
format: ## Format code using clang-format (if available)
	@echo "Formatting code..."
	@find . -name "*.c" -o -name "*.h" | xargs clang-format -i
	@echo "Formatting complete!"

.PHONY: lint
lint: ## Run static analysis with cppcheck
	@echo "Running static analysis..."
	@$(DOCKER_RUN) cppcheck --enable=all --suppress=missingIncludeSystem \
		--error-exitcode=1 \
		-I hal/include -I ccsds/include -I pus/include -I include \
		hal/ ccsds/ pus/ app/ src/
	@echo "Static analysis complete!"

# =============================================================================
# Documentation
# =============================================================================

.PHONY: docs
docs: ## Generate documentation with Doxygen
	@echo "Generating documentation..."
	@$(DOCKER_RUN) doxygen Doxyfile
	@echo "Documentation generated in docs/html/"

# =============================================================================
# Utility Targets
# =============================================================================

.PHONY: size
size: ## Show firmware size information
	@echo "Firmware size:"
	@$(DOCKER_RUN) arm-none-eabi-size $(BUILD_DIR)/app/$(PROJECT_NAME).out || \
		echo "Note: arm-none-eabi-size not available, use TI size tool"

.PHONY: info
info: ## Show project information
	@echo "Nexus Flight Software"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Docker Image: $(DOCKER_FULL)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "Target MCU: TMS570LC4357"
	@echo ""
	@echo "Quick start:"
	@echo "  1. make toolchain-build   # Build Docker toolchain (first time)"
	@echo "  2. make all               # Configure and build"
	@echo "  3. make flash             # Flash to target"
	@echo ""

# =============================================================================
# Development Workflow Shortcuts
# =============================================================================

.PHONY: dev
dev: all ## Quick development cycle: configure and build

.PHONY: deploy
deploy: build flash ## Build and flash firmware

.PHONY: deploy-release
deploy-release: release flash-release ## Build release and flash

# Default target
.DEFAULT_GOAL := help
