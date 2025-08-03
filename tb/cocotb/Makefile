#=============================================================================
# MLow Codec - Cocotb Makefile
#=============================================================================
# Description: Makefile for cocotb-based verification of MLow codec
#              Supports multiple simulators and comprehensive testing
#
# Author:      Vyges Team
# Date:        2025-08-02T16:08:15Z
# Version:     1.0.0
# License:     Apache-2.0
#=============================================================================

# Defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Project configuration
PROJECT_NAME = mlow_codec
TOPLEVEL = mlow_codec
MODULE = test_mlow_codec

# RTL source files
RTL_SOURCES = ../../rtl/mlow_codec.sv
RTL_SOURCES += ../../rtl/audio_interface.sv

# Test configuration
TEST_CONFIG = --test-config=test_config.json
COVERAGE = --coverage=functional
VERBOSE = --verbose

# Simulator-specific settings
ifeq ($(SIM),icarus)
    COMPILE_ARGS += -g2012
    EXTRA_ARGS += -I../../rtl
    VERILOG_SOURCES = $(RTL_SOURCES)
else ifeq ($(SIM),verilator)
    COMPILE_ARGS += -Wall -Wno-DECLFILENAME
    EXTRA_ARGS += -I../../rtl
    VERILOG_SOURCES = $(RTL_SOURCES)
else ifeq ($(SIM),ghdl)
    COMPILE_ARGS += --std=08
    EXTRA_ARGS += -I../../rtl
    VHDL_SOURCES = $(RTL_SOURCES)
else ifeq ($(SIM),modelsim)
    COMPILE_ARGS += -sv
    EXTRA_ARGS += -I../../rtl
    VERILOG_SOURCES = $(RTL_SOURCES)
else ifeq ($(SIM),xcelium)
    COMPILE_ARGS += -sv
    EXTRA_ARGS += -I../../rtl
    VERILOG_SOURCES = $(RTL_SOURCES)
else ifeq ($(SIM),vcs)
    COMPILE_ARGS += -sverilog
    EXTRA_ARGS += -I../../rtl
    VERILOG_SOURCES = $(RTL_SOURCES)
endif

# Check if cocotb is available
COCOTB_AVAILABLE := $(shell which cocotb-config 2>/dev/null)

# Include cocotb's make rules if available
ifdef COCOTB_AVAILABLE
    include $(shell cocotb-config --makefiles)/Makefile.sim
else
    # Fallback when cocotb is not available
    sim:
	@echo "⚠️  cocotb not found. Install with: pip install cocotb"
	@echo "   Skipping cocotb tests"
	@echo "✓ Fallback completed (cocotb not available)"
endif

#=============================================================================
# Custom Targets
#=============================================================================

.PHONY: all clean test test-quick test-full coverage report help

# Default target
all: test

# Quick test (basic functionality)
test-quick: SIM_ARGS += --test-filter="test_initialization or test_encoding_functionality"
test-quick: sim

# Full test suite
test-full: SIM_ARGS += --test-filter="test_*"
test-full: sim

# Test with coverage
coverage: SIM_ARGS += $(COVERAGE)
coverage: test-full

# Generate test report
report: coverage
	@echo "Generating test report..."
	@if [ -f "sim_build/results.xml" ]; then \
		echo "Test results available in sim_build/results.xml"; \
	fi
	@if [ -f "sim_build/coverage.xml" ]; then \
		echo "Coverage results available in sim_build/coverage.xml"; \
	fi

# Run specific test
test-%: SIM_ARGS += --test-filter="test_$*"
test-%: sim

# Performance test
test-performance: SIM_ARGS += --test-filter="test_performance_metrics"
test-performance: sim

# Error condition test
test-errors: SIM_ARGS += --test-filter="test_error_conditions"
test-errors: sim

# End-to-end test
test-e2e: SIM_ARGS += --test-filter="test_end_to_end_verification"
test-e2e: sim

#=============================================================================
# Verification Targets
#=============================================================================

# Run all verification
verify: test-full coverage report

# Run regression tests
regression: clean test-full
	@echo "Regression test completed"

# Run smoke tests
smoke: test-quick
	@echo "Smoke test completed"

#=============================================================================
# Analysis Targets
#=============================================================================

# Analyze code coverage
analyze-coverage:
	@echo "Analyzing code coverage..."
	@if [ -f "sim_build/coverage.xml" ]; then \
		python3 -c "import xml.etree.ElementTree as ET; \
		tree = ET.parse('sim_build/coverage.xml'); \
		root = tree.getroot(); \
		print('Coverage Analysis:'); \
		for elem in root.findall('.//coverage'): \
			print(f'  {elem.get(\"name\")}: {elem.get(\"percentage\")}%');" \
	else \
		echo "No coverage data available. Run 'make coverage' first."; \
	fi

# Analyze test results
analyze-results:
	@echo "Analyzing test results..."
	@if [ -f "sim_build/results.xml" ]; then \
		python3 -c "import xml.etree.ElementTree as ET; \
		tree = ET.parse('sim_build/results.xml'); \
		root = tree.getroot(); \
		passed = len(root.findall('.//testcase[@result=\"passed\"]')); \
		failed = len(root.findall('.//testcase[@result=\"failed\"]')); \
		total = passed + failed; \
		print(f'Test Results:'); \
		print(f'  Passed: {passed}'); \
		print(f'  Failed: {failed}'); \
		print(f'  Total: {total}'); \
		if total > 0: \
			print(f'  Pass Rate: {(passed/total)*100:.1f}%');" \
	else \
		echo "No test results available. Run 'make test' first."; \
	fi

#=============================================================================
# Documentation Targets
#=============================================================================

# Generate test documentation
docs:
	@echo "Generating test documentation..."
	@mkdir -p docs
	@echo "# MLow Codec Test Documentation" > docs/test_docs.md
	@echo "" >> docs/test_docs.md
	@echo "## Test Configuration" >> docs/test_docs.md
	@echo "- Simulator: $(SIM)" >> docs/test_docs.md
	@echo "- Top Level: $(TOPLEVEL)" >> docs/test_docs.md
	@echo "- Module: $(MODULE)" >> docs/test_docs.md
	@echo "" >> docs/test_docs.md
	@echo "## Test Cases" >> docs/test_docs.md
	@echo "1. test_initialization - DUT initialization and reset" >> docs/test_docs.md
	@echo "2. test_encoding_functionality - Encoding at various bitrates" >> docs/test_docs.md
	@echo "3. test_decoding_functionality - Decoding functionality" >> docs/test_docs.md
	@echo "4. test_audio_patterns - Different audio pattern testing" >> docs/test_docs.md
	@echo "5. test_performance_metrics - Performance and timing tests" >> docs/test_docs.md
	@echo "6. test_error_conditions - Error handling and edge cases" >> docs/test_docs.md
	@echo "7. test_end_to_end_verification - Complete encode/decode cycle" >> docs/test_docs.md
	@echo "Test documentation generated in docs/test_docs.md"

#=============================================================================
# Utility Targets
#=============================================================================

# Clean all generated files
clean-all: clean
	rm -rf sim_build/
	rm -rf docs/
	rm -f *.vcd
	rm -f *.log
	rm -f results.xml
	rm -f coverage.xml

# Show help
help:
	@echo "MLow Codec Testbench - Available Targets:"
	@echo ""
	@echo "Testing:"
	@echo "  test-quick      - Run quick smoke tests"
	@echo "  test-full       - Run complete test suite"
	@echo "  test-performance - Run performance tests"
	@echo "  test-errors     - Run error condition tests"
	@echo "  test-e2e        - Run end-to-end tests"
	@echo "  coverage        - Run tests with coverage"
	@echo ""
	@echo "Verification:"
	@echo "  verify          - Run all verification"
	@echo "  regression      - Run regression tests"
	@echo "  smoke           - Run smoke tests"
	@echo ""
	@echo "Analysis:"
	@echo "  analyze-coverage - Analyze code coverage"
	@echo "  analyze-results  - Analyze test results"
	@echo "  report          - Generate test report"
	@echo ""
	@echo "Documentation:"
	@echo "  docs            - Generate test documentation"
	@echo ""
	@echo "Utilities:"
	@echo "  clean           - Clean simulation files"
	@echo "  clean-all       - Clean all generated files"
	@echo "  help            - Show this help"
	@echo ""
	@echo "Environment Variables:"
	@echo "  SIM             - Simulator (icarus, verilator, ghdl, modelsim, xcelium, vcs)"
	@echo "  TOPLEVEL_LANG   - Top level language (verilog, vhdl)"
	@echo "  COVERAGE        - Coverage options"
	@echo "  VERBOSE         - Verbose output"

#=============================================================================
# Simulator-Specific Configurations
#=============================================================================

# Icarus Verilog specific
icarus-config:
	@echo "Configuring for Icarus Verilog..."
	@echo "SIM=icarus"
	@echo "TOPLEVEL_LANG=verilog"
	@echo "COMPILE_ARGS=-g2012"
	@echo "EXTRA_ARGS=-I../../rtl"

# Verilator specific
verilator-config:
	@echo "Configuring for Verilator..."
	@echo "SIM=verilator"
	@echo "TOPLEVEL_LANG=verilog"
	@echo "COMPILE_ARGS=-Wall -Wno-DECLFILENAME"
	@echo "EXTRA_ARGS=-I../../rtl"

# GHDL specific
ghdl-config:
	@echo "Configuring for GHDL..."
	@echo "SIM=ghdl"
	@echo "TOPLEVEL_LANG=vhdl"
	@echo "COMPILE_ARGS=--std=08"
	@echo "EXTRA_ARGS=-I../../rtl"

# ModelSim specific
modelsim-config:
	@echo "Configuring for ModelSim..."
	@echo "SIM=modelsim"
	@echo "TOPLEVEL_LANG=verilog"
	@echo "COMPILE_ARGS=-sv"
	@echo "EXTRA_ARGS=-I../../rtl"

#=============================================================================
# Test Configuration File
#=============================================================================

# Generate test configuration
test-config:
	@echo "Generating test configuration..."
	@echo '{' > test_config.json
	@echo '  "project": "mlow_codec",' >> test_config.json
	@echo '  "version": "1.0.0",' >> test_config.json
	@echo '  "simulator": "$(SIM)",' >> test_config.json
	@echo '  "test_parameters": {' >> test_config.json
	@echo '    "CLK_PERIOD_NS": 20,' >> test_config.json
	@echo '    "SAMPLE_RATE": 48000,' >> test_config.json
	@echo '    "FRAME_SIZE": 480,' >> test_config.json
	@echo '    "MAX_BITRATE": 32000,' >> test_config.json
	@echo '    "LPC_ORDER": 16,' >> test_config.json
	@echo '    "SUBBAND_COUNT": 2' >> test_config.json
	@echo '  },' >> test_config.json
	@echo '  "bitrate_configs": {' >> test_config.json
	@echo '    "0": {"bitrate": 6000, "quality_target": 60},' >> test_config.json
	@echo '    "1": {"bitrate": 8000, "quality_target": 65},' >> test_config.json
	@echo '    "2": {"bitrate": 12000, "quality_target": 70},' >> test_config.json
	@echo '    "3": {"bitrate": 16000, "quality_target": 75},' >> test_config.json
	@echo '    "4": {"bitrate": 20000, "quality_target": 80},' >> test_config.json
	@echo '    "5": {"bitrate": 24000, "quality_target": 85},' >> test_config.json
	@echo '    "6": {"bitrate": 28000, "quality_target": 90},' >> test_config.json
	@echo '    "7": {"bitrate": 32000, "quality_target": 95}' >> test_config.json
	@echo '  },' >> test_config.json
	@echo '  "bandwidth_configs": {' >> test_config.json
	@echo '    "0": {"name": "NarrowBand", "freq_range": "0-4kHz"},' >> test_config.json
	@echo '    "1": {"name": "WideBand", "freq_range": "0-8kHz"},' >> test_config.json
	@echo '    "2": {"name": "SuperWideBand", "freq_range": "0-16kHz"}' >> test_config.json
	@echo '  }' >> test_config.json
	@echo '}' >> test_config.json
	@echo "Test configuration generated in test_config.json"

#=============================================================================
# Dependencies
#=============================================================================

# Check dependencies
check-deps:
	@echo "Checking dependencies..."
	@python3 -c "import cocotb" 2>/dev/null || (echo "Error: cocotb not found. Install with: pip install cocotb" && exit 1)
	@python3 -c "import numpy" 2>/dev/null || (echo "Error: numpy not found. Install with: pip install numpy" && exit 1)
	@which $(SIM) >/dev/null 2>&1 || (echo "Error: $(SIM) simulator not found" && exit 1)
	@echo "All dependencies satisfied"

# Install dependencies
install-deps:
	@echo "Installing dependencies..."
	pip install cocotb numpy
	@echo "Dependencies installed"

#=============================================================================
# Default Rules
#=============================================================================

# Ensure test configuration exists
sim: test-config
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim

# Show configuration
config:
	@echo "Current Configuration:"
	@echo "  SIM: $(SIM)"
	@echo "  TOPLEVEL: $(TOPLEVEL)"
	@echo "  MODULE: $(MODULE)"
	@echo "  TOPLEVEL_LANG: $(TOPLEVEL_LANG)"
	@echo "  RTL_SOURCES: $(RTL_SOURCES)"
	@echo "  COMPILE_ARGS: $(COMPILE_ARGS)"
	@echo "  EXTRA_ARGS: $(EXTRA_ARGS)" 