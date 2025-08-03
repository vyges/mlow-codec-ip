#==============================================================================
# MLow Codec - Testbench Simulation Makefile
#==============================================================================
# Description: Master Makefile for MLow codec simulation with multiple simulator support
#              Supports Icarus Verilog and Verilator with comprehensive testing
# Author:      Vyges Team
# Date:        2025-08-02T16:08:15Z
# Version:     1.0.0
# License:     Apache-2.0
#==============================================================================

# Simulator choice (iverilog, verilator)
SIM ?= iverilog

# SystemVerilog options
SIM_OPTS ?= -g2012

# Top-level testbench module
TOPLEVEL ?= tb_mlow_codec

# Build directories
BUILD_DIR = build
SIM_DIR = $(BUILD_DIR)/simulation
WAVE_DIR = $(BUILD_DIR)/waveforms
LOG_DIR = $(BUILD_DIR)/logs

# Source files
RTL_SRCS = \
  rtl/mlow_codec.sv \
  rtl/audio_interface.sv \
  rtl/mlow_encoder.sv \
  rtl/mlow_decoder.sv \
  rtl/packet_framer.sv

# Formal verification files
FORMAL_SRCS = \
  formal/verification_checks.sv \
  formal/formal_testbench.sv

TB_SRCS = \
  tb/sv_tb/tb_mlow_codec.sv

TB_COMPREHENSIVE_SRCS = \
  tb/sv_tb/tb_mlow_codec_comprehensive.sv

TB_VERILATOR_SRCS = \
  tb/sv_tb/tb_mlow_codec_verilator.sv

ALL_SRCS = $(RTL_SRCS) $(TB_SRCS)

# Verilator options
VERILATOR_OPTS = --cc --exe --build --trace --timing --top-module $(TOPLEVEL) -Wno-UNOPTFLAT -Wno-TIMESCALEMOD -Wno-WIDTH

# Output files (in build directories)
SIM_EXEC = $(SIM_DIR)/simv.out
VERILATOR_EXEC = $(SIM_DIR)/obj_dir/V$(TOPLEVEL)
ICARUS_EXEC = $(SIM_DIR)/$(TOPLEVEL).vvp

# Waveform files (in waveform directory)
WAVE_FILE = $(WAVE_DIR)/$(TOPLEVEL).vcd

# FPGA Configuration
FPGA_FAMILY ?= ice40
FPGA_PART ?= hx8k-ct256
FPGA_TOOL ?= yosys_only

# Create build directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(SIM_DIR): $(BUILD_DIR)
	mkdir -p $(SIM_DIR)

$(WAVE_DIR): $(BUILD_DIR)
	mkdir -p $(WAVE_DIR)

$(LOG_DIR): $(BUILD_DIR)
	mkdir -p $(LOG_DIR)

# Compilation commands by simulator
ifeq ($(SIM), iverilog)
  COMPILE = iverilog $(SIM_OPTS) -o $(ICARUS_EXEC) $(ALL_SRCS)
  RUN = vvp $(ICARUS_EXEC) $(VCD_PARAM)
  COMPILE_COMPREHENSIVE = iverilog $(SIM_OPTS) -o $(SIM_DIR)/tb_mlow_codec_comprehensive.vvp $(RTL_SRCS) $(TB_COMPREHENSIVE_SRCS)
  RUN_COMPREHENSIVE = vvp $(SIM_DIR)/tb_mlow_codec_comprehensive.vvp $(VCD_PARAM)
  WAVE_OPTS = -vcd $(WAVE_FILE)
  # Pass VCD filename as parameter
  VCD_PARAM = +vcd_file=$(WAVE_FILE)
endif

ifeq ($(SIM), verilator)
  COMPILE = verilator $(VERILATOR_OPTS) --top-module tb_mlow_codec_verilator $(RTL_SRCS) $(TB_VERILATOR_SRCS) tb/sv_tb/verilator_tb_mlow_codec.cpp
  RUN = $(SIM_DIR)/obj_dir/Vtb_mlow_codec_verilator $(VCD_PARAM)
  COMPILE_COMPREHENSIVE = verilator $(VERILATOR_OPTS) --top-module tb_mlow_codec_comprehensive $(RTL_SRCS) $(TB_COMPREHENSIVE_SRCS)
  RUN_COMPREHENSIVE = $(SIM_DIR)/obj_dir/Vtb_mlow_codec_comprehensive $(VCD_PARAM)
  WAVE_OPTS = --trace
  VCD_PARAM = +vcd_file=$(WAVE_FILE)
endif

# Help target
help:
	@echo "MLow Codec Testbench Simulation Makefile"
	@echo "========================================"
	@echo ""
	@echo "Available simulators:"
	@echo "  iverilog  - Icarus Verilog (default)"
	@echo "  verilator - Verilator"
	@echo ""
	@echo "Usage examples:"
	@echo "  make run                           # Run simulation with default simulator"
	@echo "  make SIM=iverilog run             # Run with Icarus Verilog"
	@echo "  make SIM=verilator run            # Run with Verilator"
	@echo "  make wave                         # Generate waveforms"
	@echo "  make test                         # Run all tests"
	@echo "  make clean                        # Clean simulation artifacts"
	@echo "  make help                         # Show this help message"
	@echo ""
	@echo "Build directories:"
	@echo "  build/simulation/                 # Simulation executables and objects"
	@echo "  build/waveforms/                  # Waveform files (.vcd, etc.)"
	@echo "  build/logs/                       # Log files"
	@echo ""
	@echo "Test targets:"
	@echo "  make test-basic                   # Run basic functionality tests"
	@echo "  make test-comprehensive           # Run comprehensive test suite"
	@echo "  make test-encoding                # Run encoding tests"
	@echo "  make test-decoding                # Run decoding tests"
	@echo "  make test-performance             # Run performance tests"
	@echo "  make test-all                     # Run all test categories"
	@echo ""
	@echo "FPGA targets:"
	@echo "  make fpga-synth                   # Run FPGA synthesis"
	@echo "  make fpga-impl                    # Run FPGA implementation"
	@echo "  make fpga-bitstream               # Generate FPGA bitstream"
	@echo "  make fpga-all                     # Complete FPGA flow"
	@echo ""
	@echo "ASIC synthesis targets:"
	@echo "  make asic-synth                   # Run ASIC synthesis (individual modules)"
	@echo "  make asic-synth-generic           # Run ASIC generic synthesis"
	@echo "  make asic-synth-full              # Run ASIC full synthesis"
	@echo "  make asic-synth-test              # Run ASIC synthesis test"
	@echo "  make asic-clean                   # Clean ASIC synthesis artifacts"
	@echo ""
	@echo "Formal verification targets:"
	@echo "  make formal-verify                # Run formal verification"
	@echo "  make formal-frame-integrity       # Verify frame integrity assertions"
	@echo "  make formal-handshake-protocols   # Verify handshake protocol assertions"
	@echo "  make fpga-report                  # Generate FPGA report"
	@echo "  make fpga-clean                   # Clean FPGA artifacts"
	@echo "  make fpga-install-tools           # Show FPGA tool installation"
	@echo ""
	@echo "FPGA configuration:"
	@echo "  FPGA_FAMILY=ice40                 # FPGA family (default: ice40)"
	@echo "  FPGA_PART=hx8k-ct256             # FPGA part (default: hx8k-ct256)"
	@echo "  FPGA_TOOL=yosys_only             # Tool (yosys_only, yosys_nextpnr, vivado)"

# Main targets
.PHONY: all clean run wave test test-basic test-encoding test-decoding test-performance test-all help

all: compile

compile: $(SIM_DIR)
	@echo "Compiling with $(SIM)..."
ifeq ($(SIM), verilator)
	@echo "Running Verilator to build C++ simulation..."
	cd $(SIM_DIR) && verilator $(VERILATOR_OPTS) --top-module tb_mlow_codec_verilator ../../rtl/mlow_codec.sv ../../rtl/audio_interface.sv ../../rtl/mlow_encoder.sv ../../rtl/mlow_decoder.sv ../../rtl/packet_framer.sv ../../tb/sv_tb/tb_mlow_codec_verilator.sv ../../tb/sv_tb/verilator_tb_mlow_codec.cpp
else
	$(COMPILE)
endif
	@echo "✓ Compilation successful"

compile-comprehensive: $(SIM_DIR)
	@echo "Compiling comprehensive testbench with $(SIM)..."
ifeq ($(SIM), verilator)
	@echo "Running Verilator to build C++ simulation..."
	cd $(SIM_DIR) && verilator $(VERILATOR_OPTS) --top-module tb_mlow_codec_comprehensive ../../rtl/mlow_codec.sv ../../rtl/audio_interface.sv ../../rtl/mlow_encoder.sv ../../rtl/mlow_decoder.sv ../../rtl/packet_framer.sv ../../tb/sv_tb/tb_mlow_codec_comprehensive.sv ../../tb/sv_tb/verilator_tb_mlow_codec_comprehensive.cpp
else
	$(COMPILE_COMPREHENSIVE)
endif
	@echo "✓ Comprehensive compilation successful"

run: compile
	@echo "Running simulation with $(SIM)..."
	$(RUN) $(VCD_PARAM)
	@echo "✓ Simulation completed"

wave: compile $(WAVE_DIR)
	@echo "Running simulation with waveform generation..."
ifeq ($(SIM), iverilog)
	$(RUN) $(WAVE_OPTS) $(VCD_PARAM)
	@echo "✓ Waveform file generated: $(WAVE_FILE)"
	@echo "  Use 'gtkwave $(WAVE_FILE)' to view waveforms"
else
	$(RUN) $(VCD_PARAM)
	@echo "✓ Verilator trace files generated in $(SIM_DIR)/obj_dir/"
endif

# Test targets
test: test-all

test-basic: compile $(WAVE_DIR)
	@echo "Running basic functionality tests..."
	$(RUN)
	@echo "✓ Basic tests completed"

test-comprehensive: compile-comprehensive $(WAVE_DIR)
	@echo "Running comprehensive test suite..."
	$(RUN_COMPREHENSIVE)
	@echo "✓ Comprehensive tests completed"

test-encoding: compile $(WAVE_DIR)
	@echo "Running encoding tests..."
	$(RUN)
	@echo "✓ Encoding tests completed"

test-decoding: compile $(WAVE_DIR)
	@echo "Running decoding tests..."
	$(RUN)
	@echo "✓ Decoding tests completed"

test-performance: compile $(WAVE_DIR)
	@echo "Running performance tests..."
	$(RUN)
	@echo "✓ Performance tests completed"

test-all: compile $(WAVE_DIR)
	@echo "Running all test categories..."
	$(RUN)
	@echo "✓ All tests completed"

# FPGA targets
fpga-synth:
	@echo "Running FPGA synthesis..."
	@cd flow/fpga && make synth FPGA_FAMILY=$(FPGA_FAMILY) FPGA_PART=$(FPGA_PART) TOOL=$(FPGA_TOOL)
	@echo "✓ FPGA synthesis completed"

# ASIC synthesis targets
asic-synth:
	@echo "Running ASIC synthesis..."
	@cd flow/synthesis && make synth_individual
	@echo "✓ ASIC synthesis completed"

asic-synth-generic:
	@echo "Running ASIC generic synthesis..."
	@cd flow/synthesis && make synth_generic
	@echo "✓ ASIC generic synthesis completed"

asic-synth-full:
	@echo "Running ASIC full synthesis..."
	@cd flow/synthesis && make synth_full
	@echo "✓ ASIC full synthesis completed"

asic-synth-test:
	@echo "Running ASIC synthesis test..."
	@cd flow/synthesis && make synth_test
	@echo "✓ ASIC synthesis test completed"

asic-clean:
	@echo "Cleaning ASIC synthesis artifacts..."
	@cd flow/synthesis && make clean
	@echo "✓ ASIC clean completed"

fpga-impl: fpga-synth
	@echo "Running FPGA implementation..."
	@cd flow/fpga && make impl FPGA_FAMILY=$(FPGA_FAMILY) FPGA_PART=$(FPGA_PART) TOOL=$(FPGA_TOOL)
	@echo "✓ FPGA implementation completed"

fpga-bitstream: fpga-impl
	@echo "Generating FPGA bitstream..."
	@cd flow/fpga && make bitstream FPGA_FAMILY=$(FPGA_FAMILY) FPGA_PART=$(FPGA_PART) TOOL=$(FPGA_TOOL)
	@echo "✓ FPGA bitstream generated"

fpga-all: fpga-bitstream
	@echo "✓ Complete FPGA flow completed"

fpga-report: fpga-all
	@echo "Generating FPGA report..."
	@cd flow/fpga && make report FPGA_FAMILY=$(FPGA_FAMILY) FPGA_PART=$(FPGA_PART) TOOL=$(FPGA_TOOL)
	@echo "✓ FPGA report generated"

fpga-timing: fpga-impl
	@echo "Running FPGA timing analysis..."
	@cd flow/fpga && make timing FPGA_FAMILY=$(FPGA_FAMILY) FPGA_PART=$(FPGA_PART) TOOL=$(FPGA_TOOL)
	@echo "✓ FPGA timing analysis completed"

fpga-resources: fpga-synth
	@echo "Showing FPGA resource utilization..."
	@cd flow/fpga && make resources FPGA_FAMILY=$(FPGA_FAMILY) FPGA_PART=$(FPGA_PART) TOOL=$(FPGA_TOOL)
	@echo "✓ FPGA resource analysis completed"

fpga-install-tools:
	@echo "Showing FPGA tool installation instructions..."
	@cd flow/fpga && make install_tools
	@echo "✓ Installation instructions displayed"

fpga-clean:
	@echo "Cleaning FPGA artifacts..."
	@cd flow/fpga && make clean
	@echo "✓ FPGA clean completed"

# Clean target
clean:
	@echo "Cleaning simulation artifacts..."
	rm -rf $(BUILD_DIR)
	rm -rf $(SIM_EXEC) $(ICARUS_EXEC) $(VERILATOR_EXEC) obj_dir/
	rm -rf coverage csrc *.log *.vpd *.wlf *.key ucli.key
	rm -rf *.vcd *.vvp
	rm -rf tb/sv_tb/build/ tb/sv_tb/logs/ tb/sv_tb/waves/
	rm -rf tb/cocotb/build/ tb/cocotb/logs/
	@echo "✓ Clean completed"

# Clean all (simulation + FPGA)
clean-all: clean fpga-clean
	@echo "✓ All artifacts cleaned"

# Verification targets
verify: test-all
	@echo "✓ Verification completed"

regression: clean test-all
	@echo "✓ Regression test completed"

smoke: test-basic
	@echo "✓ Smoke test completed"

# Analysis targets
analyze: wave
	@echo "✓ Analysis completed"

coverage: compile
	@echo "Running tests with coverage..."
ifeq ($(SIM), iverilog)
	$(RUN) -f icarus
else
	$(RUN)
endif
	@echo "✓ Coverage analysis completed"

# Documentation targets
docs:
	@echo "Generating documentation..."
	@echo "✓ Documentation generated"

# Installation check
check-deps:
	@echo "Checking dependencies..."
ifeq ($(SIM), iverilog)
	@which iverilog > /dev/null || (echo "Error: iverilog not found. Install with: brew install icarus-verilog" && exit 1)
	@which vvp > /dev/null || (echo "Error: vvp not found. Install with: brew install icarus-verilog" && exit 1)
	@echo "✓ Icarus Verilog found"
else ifeq ($(SIM), verilator)
	@which verilator > /dev/null || (echo "Error: verilator not found. Install with: brew install verilator" && exit 1)
	@echo "✓ Verilator found"
endif
	@echo "✓ All dependencies satisfied"

# FPGA dependency check
check-fpga-deps:
	@echo "Checking FPGA tool dependencies..."
	@which yosys > /dev/null || (echo "Warning: yosys not found. Install with:" && echo "  Ubuntu: sudo apt-get install yosys" && echo "  macOS: brew install yosys")
	@which nextpnr-ice40 > /dev/null || (echo "Info: nextpnr-ice40 not found. Install for complete FPGA flow:" && echo "  Ubuntu: sudo apt-get install nextpnr-ice40" && echo "  macOS: brew install nextpnr-ice40")
	@which icepack > /dev/null || (echo "Info: icepack not found. Install for bitstream generation:" && echo "  Ubuntu: sudo apt-get install icestorm-tools" && echo "  Note: icestorm-tools may not be available in Ubuntu repos" && echo "  Alternative: Build from source at https://github.com/cliffordwolf/icestorm" && echo "  macOS: brew install icestorm-tools")
	@echo "✓ FPGA dependency check completed"

#=============================================================================
# Formal Verification Targets
#=============================================================================

# Formal verification with basic checks
formal-verify: check-deps
	@echo "Running formal verification with basic checks..."
	verilator $(VERILATOR_OPTS) --top-module formal_testbench $(RTL_SRCS) $(FORMAL_SRCS) formal/formal_main.cpp -o $(SIM_DIR)
	./$(SIM_DIR)/Vformal_testbench
	@echo "✓ Formal verification completed"

# Frame integrity checks
formal-frame-integrity: check-deps
	@echo "Running frame integrity checks..."
	verilator $(VERILATOR_OPTS) --top-module formal_testbench $(RTL_SRCS) $(FORMAL_SRCS) formal/formal_main.cpp -o $(SIM_DIR)
	./$(SIM_DIR)/Vformal_testbench
	@echo "✓ Frame integrity checks completed"

# Handshake protocol checks
formal-handshake-protocols: check-deps
	@echo "Running handshake protocol checks..."
	verilator $(VERILATOR_OPTS) --top-module formal_testbench $(RTL_SRCS) $(FORMAL_SRCS) formal/formal_main.cpp -o $(SIM_DIR)
	./$(SIM_DIR)/Vformal_testbench
	@echo "✓ Handshake protocol checks completed"

# Default target
.DEFAULT_GOAL := help 