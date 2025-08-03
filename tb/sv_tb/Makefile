#=============================================================================
# MLow Codec - SystemVerilog Testbench Makefile
#=============================================================================
# Description: Simplified Makefile for SystemVerilog-based verification
#              Optimized for Icarus Verilog and Verilator
#
# Author:      Vyges Team
# Date:        2025-08-02T16:08:15Z
# Version:     1.0.0
# License:     Apache-2.0
#=============================================================================

# Simulator choice (iverilog, verilator)
SIM ?= iverilog

# SystemVerilog options
SIM_OPTS ?= -g2012

# Top-level testbench module
TOPLEVEL ?= tb_mlow_codec

# Source files
RTL_SRCS = \
  ../../rtl/mlow_codec.sv \
  ../../rtl/audio_interface.sv

TB_SRCS = \
  ./tb_mlow_codec.sv

ALL_SRCS = $(RTL_SRCS) $(TB_SRCS)

# Verilator options
VERILATOR_OPTS = --cc --exe --build --trace --top-module $(TOPLEVEL)

# Output files
SIM_EXEC = simv.out
VERILATOR_EXEC = obj_dir/V$(TOPLEVEL)
ICARUS_EXEC = $(TOPLEVEL).vvp

# Waveform files
WAVE_FILE = $(TOPLEVEL).vcd

# Compilation commands by simulator
ifeq ($(SIM), iverilog)
  COMPILE = iverilog $(SIM_OPTS) -o $(ICARUS_EXEC) $(ALL_SRCS)
  RUN = vvp $(ICARUS_EXEC)
  WAVE_OPTS = -vcd $(WAVE_FILE)
endif

ifeq ($(SIM), verilator)
  COMPILE = verilator $(VERILATOR_OPTS) $(ALL_SRCS)
  RUN = ./$(VERILATOR_EXEC)
  WAVE_OPTS = --trace
endif

# Help target
help:
	@echo "MLow Codec SystemVerilog Testbench"
	@echo "==================================="
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

# Main targets
.PHONY: all clean run wave test help

all: compile

compile:
	@echo "Compiling with $(SIM)..."
ifeq ($(SIM), verilator)
	@echo "Running Verilator to build C++ simulation..."
	$(COMPILE)
else
	$(COMPILE)
endif
	@echo "✓ Compilation successful"

run: compile
	@echo "Running simulation with $(SIM)..."
	$(RUN)
	@echo "✓ Simulation completed"

wave: compile
	@echo "Running simulation with waveform generation..."
ifeq ($(SIM), iverilog)
	$(RUN) $(WAVE_OPTS)
	@echo "✓ Waveform file generated: $(WAVE_FILE)"
	@echo "  Use 'gtkwave $(WAVE_FILE)' to view waveforms"
else
	$(RUN)
	@echo "✓ Verilator trace files generated in obj_dir/"
endif

# Test targets
test: run
	@echo "✓ All tests completed"

test-quick: run
	@echo "✓ Quick tests completed"

test-full: run
	@echo "✓ Full tests completed"

# Clean target
clean:
	@echo "Cleaning simulation artifacts..."
	rm -rf $(SIM_EXEC) $(ICARUS_EXEC) $(VERILATOR_EXEC) obj_dir/
	rm -rf coverage csrc *.log *.vpd *.wlf *.key ucli.key
	rm -rf $(WAVE_FILE) *.vcd
	rm -rf build/ logs/ waves/
	@echo "✓ Clean completed"

# Default target
.DEFAULT_GOAL := help 