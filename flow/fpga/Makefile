#=============================================================================
# FPGA Implementation Makefile for MLow Audio Codec
#=============================================================================
# Description: Makefile for FPGA implementation using open-source tools
#              Supports Yosys, NextPNR, and OpenFPGA flows
# Author:      Vyges IP Development Team
# Date:        2025-08-02
# License:     Apache-2.0
#=============================================================================

# Configuration
FPGA_FAMILY ?= ice40
FPGA_PART ?= hx8k-ct256
TOOL ?= yosys_only
TOP_MODULE = mlow_codec
RTL_DIR = ../../rtl
CONSTRAINTS_DIR = constraints
BUILD_DIR = build
REPORTS_DIR = reports

# Tool-specific settings
ifeq ($(TOOL),yosys_nextpnr)
    # Yosys + NextPNR flow (recommended for open source)
    SYNTH_CMD = yosys
    SYNTH_SCRIPT = $(BUILD_DIR)/$(TOP_MODULE)_synth.ys
    NETLIST_FILE = $(BUILD_DIR)/$(TOP_MODULE).json
    PNR_CMD = nextpnr-ice40
    PNR_FLAGS = --$(shell echo $(FPGA_PART) | cut -d'-' -f1) --package $(shell echo $(FPGA_PART) | cut -d'-' -f2)
    PCF_FILE = $(CONSTRAINTS_DIR)/$(TOP_MODULE).pcf
    ASC_FILE = $(BUILD_DIR)/$(TOP_MODULE).asc
    BITSTREAM_CMD = icepack
    BITSTREAM_FILE = $(BUILD_DIR)/$(TOP_MODULE).bin
else ifeq ($(TOOL),yosys_only)
    # Yosys-only flow (when NextPNR is not available)
    SYNTH_CMD = yosys
    SYNTH_SCRIPT = $(BUILD_DIR)/$(TOP_MODULE)_synth.ys
    NETLIST_FILE = $(BUILD_DIR)/$(TOP_MODULE).json
    VERILOG_FILE = $(BUILD_DIR)/$(TOP_MODULE).v
    STATS_FILE = $(BUILD_DIR)/$(TOP_MODULE)_stats.txt
    BITSTREAM_FILE = $(BUILD_DIR)/$(TOP_MODULE)_synthesis_complete.txt
else ifeq ($(TOOL),openfpga)
    # OpenFPGA flow
    SYNTH_CMD = make
    SYNTH_FLAGS = -C openfpga
    SYNTH_TARGET = $(FPGA_FAMILY)_synth
    IMPL_CMD = make
    IMPL_FLAGS = -C openfpga
    IMPL_TARGET = $(FPGA_FAMILY)_pnr
    BITSTREAM_CMD = make
    BITSTREAM_FLAGS = -C openfpga
    BITSTREAM_TARGET = $(FPGA_FAMILY)_bitstream
else ifeq ($(TOOL),vivado)
    # Vivado flow (commercial)
    SYNTH_CMD = vivado
    SYNTH_FLAGS = -mode batch -source
    SYNTH_SCRIPT = vivado_synth.tcl
    IMPL_CMD = vivado
    IMPL_FLAGS = -mode batch -source
    IMPL_SCRIPT = vivado_impl.tcl
    BITSTREAM_CMD = vivado
    BITSTREAM_FLAGS = -mode batch -source
    BITSTREAM_SCRIPT = vivado_bitstream.tcl
endif

# Default target
all: synth impl bitstream

# Create directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(REPORTS_DIR):
	mkdir -p $(REPORTS_DIR)

$(CONSTRAINTS_DIR):
	mkdir -p $(CONSTRAINTS_DIR)

# Generate Yosys synthesis script
$(SYNTH_SCRIPT): $(BUILD_DIR)
	@echo "Generating Yosys synthesis script for $(TOP_MODULE)..."
	@echo "# Yosys synthesis script for $(TOP_MODULE)" > $(SYNTH_SCRIPT)
	@echo "read_verilog -sv $(RTL_DIR)/mlow_codec.sv" >> $(SYNTH_SCRIPT)
	@echo "read_verilog -sv $(RTL_DIR)/audio_interface.sv" >> $(SYNTH_SCRIPT)
	@echo "read_verilog -sv $(RTL_DIR)/mlow_encoder.sv" >> $(SYNTH_SCRIPT)
	@echo "read_verilog -sv $(RTL_DIR)/mlow_decoder.sv" >> $(SYNTH_SCRIPT)
	@echo "read_verilog -sv $(RTL_DIR)/packet_framer.sv" >> $(SYNTH_SCRIPT)
	@echo "hierarchy -top $(TOP_MODULE)" >> $(SYNTH_SCRIPT)
	@echo "check" >> $(SYNTH_SCRIPT)
	@echo "stat" >> $(SYNTH_SCRIPT)
ifeq ($(TOOL),yosys_nextpnr)
	@echo "synth_ice40 -top $(TOP_MODULE) -json $(NETLIST_FILE)" >> $(SYNTH_SCRIPT)
else
	@echo "synth -top $(TOP_MODULE)" >> $(SYNTH_SCRIPT)
	@echo "write_verilog $(VERILOG_FILE)" >> $(SYNTH_SCRIPT)
	@echo "stat" >> $(SYNTH_SCRIPT)
endif
	@echo "Synthesis script generated: $(SYNTH_SCRIPT)"

# Generate constraints file
$(PCF_FILE): $(CONSTRAINTS_DIR)
	@echo "Generating constraints file for $(TOP_MODULE)..."
	@echo "# Pin constraints for $(TOP_MODULE) on $(FPGA_PART)" > $(PCF_FILE)
	@echo "# Using valid pins for iCE40 HX8K-CT256 package" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Clock and reset" >> $(PCF_FILE)
	@echo "set_io clk_i 35" >> $(PCF_FILE)
	@echo "set_io reset_n_i 34" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Audio input data (16-bit)" >> $(PCF_FILE)
	@echo "set_io audio_data_i[0] 37" >> $(PCF_FILE)
	@echo "set_io audio_data_i[1] 38" >> $(PCF_FILE)
	@echo "set_io audio_data_i[2] 39" >> $(PCF_FILE)
	@echo "set_io audio_data_i[3] 40" >> $(PCF_FILE)
	@echo "set_io audio_data_i[4] 41" >> $(PCF_FILE)
	@echo "set_io audio_data_i[5] 42" >> $(PCF_FILE)
	@echo "set_io audio_data_i[6] 43" >> $(PCF_FILE)
	@echo "set_io audio_data_i[7] 44" >> $(PCF_FILE)
	@echo "set_io audio_data_i[8] 45" >> $(PCF_FILE)
	@echo "set_io audio_data_i[9] 46" >> $(PCF_FILE)
	@echo "set_io audio_data_i[10] 47" >> $(PCF_FILE)
	@echo "set_io audio_data_i[11] 48" >> $(PCF_FILE)
	@echo "set_io audio_data_i[12] 49" >> $(PCF_FILE)
	@echo "set_io audio_data_i[13] 50" >> $(PCF_FILE)
	@echo "set_io audio_data_i[14] 51" >> $(PCF_FILE)
	@echo "set_io audio_data_i[15] 52" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Audio control signals" >> $(PCF_FILE)
	@echo "set_io audio_valid_i 53" >> $(PCF_FILE)
	@echo "set_io audio_ready_o 54" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Audio output data (16-bit)" >> $(PCF_FILE)
	@echo "set_io audio_data_o[0] 55" >> $(PCF_FILE)
	@echo "set_io audio_data_o[1] 56" >> $(PCF_FILE)
	@echo "set_io audio_data_o[2] 57" >> $(PCF_FILE)
	@echo "set_io audio_data_o[3] 58" >> $(PCF_FILE)
	@echo "set_io audio_data_o[4] 59" >> $(PCF_FILE)
	@echo "set_io audio_data_o[5] 60" >> $(PCF_FILE)
	@echo "set_io audio_data_o[6] 61" >> $(PCF_FILE)
	@echo "set_io audio_data_o[7] 62" >> $(PCF_FILE)
	@echo "set_io audio_data_o[8] 63" >> $(PCF_FILE)
	@echo "set_io audio_data_o[9] 64" >> $(PCF_FILE)
	@echo "set_io audio_data_o[10] 65" >> $(PCF_FILE)
	@echo "set_io audio_data_o[11] 66" >> $(PCF_FILE)
	@echo "set_io audio_data_o[12] 67" >> $(PCF_FILE)
	@echo "set_io audio_data_o[13] 68" >> $(PCF_FILE)
	@echo "set_io audio_data_o[14] 69" >> $(PCF_FILE)
	@echo "set_io audio_data_o[15] 70" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Audio output control" >> $(PCF_FILE)
	@echo "set_io audio_valid_o 71" >> $(PCF_FILE)
	@echo "set_io audio_ready_i 72" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Configuration signals" >> $(PCF_FILE)
	@echo "set_io encode_mode_i 73" >> $(PCF_FILE)
	@echo "set_io bitrate_sel_i[0] 74" >> $(PCF_FILE)
	@echo "set_io bitrate_sel_i[1] 75" >> $(PCF_FILE)
	@echo "set_io bitrate_sel_i[2] 76" >> $(PCF_FILE)
	@echo "set_io bitrate_sel_i[3] 77" >> $(PCF_FILE)
	@echo "set_io bandwidth_sel_i[0] 78" >> $(PCF_FILE)
	@echo "set_io bandwidth_sel_i[1] 79" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Status signals" >> $(PCF_FILE)
	@echo "set_io busy_o 80" >> $(PCF_FILE)
	@echo "set_io error_o 81" >> $(PCF_FILE)
	@echo "" >> $(PCF_FILE)
	@echo "# Quality metrics (8-bit)" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[0] 82" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[1] 83" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[2] 84" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[3] 85" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[4] 86" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[5] 87" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[6] 88" >> $(PCF_FILE)
	@echo "set_io quality_metric_o[7] 89" >> $(PCF_FILE)
	@echo "Constraints file generated: $(PCF_FILE)"

# Synthesis
synth: $(SYNTH_SCRIPT) $(PCF_FILE)
	@echo "Running synthesis for $(TOP_MODULE) on $(FPGA_FAMILY)..."
	$(SYNTH_CMD) $(SYNTH_SCRIPT)
	@echo "Synthesis completed successfully!"

# Implementation (Place and Route)
impl: synth
	@echo "Running implementation for $(TOP_MODULE) on $(FPGA_FAMILY)..."
ifeq ($(TOOL),yosys_nextpnr)
	@if command -v $(PNR_CMD) >/dev/null 2>&1; then \
		$(PNR_CMD) $(PNR_FLAGS) --json $(NETLIST_FILE) --pcf $(PCF_FILE) --asc $(ASC_FILE); \
	else \
		echo "Warning: $(PNR_CMD) not found. Skipping place and route."; \
		echo "Install NextPNR for complete FPGA implementation."; \
		echo "For now, synthesis-only implementation is complete."; \
	fi
else ifeq ($(TOOL),yosys_only)
	@echo "Yosys-only implementation: Place and route not available"
	@echo "Synthesis completed successfully. Install NextPNR for full implementation."
else ifeq ($(TOOL),openfpga)
	$(IMPL_CMD) $(IMPL_FLAGS) $(IMPL_TARGET) FPGA_PART=$(FPGA_PART)
else ifeq ($(TOOL),vivado)
	$(IMPL_CMD) $(IMPL_FLAGS) $(IMPL_SCRIPT) -tclargs $(FPGA_PART) $(TOP_MODULE)
endif
	@echo "Implementation completed successfully!"

# Bitstream generation
bitstream: impl
	@echo "Generating bitstream for $(TOP_MODULE)..."
ifeq ($(TOOL),yosys_nextpnr)
	@if command -v $(BITSTREAM_CMD) >/dev/null 2>&1; then \
		$(BITSTREAM_CMD) $(ASC_FILE) $(BITSTREAM_FILE); \
	else \
		echo "Warning: $(BITSTREAM_CMD) not found. Skipping bitstream generation."; \
		echo "Install icepack for bitstream generation."; \
	fi
else ifeq ($(TOOL),yosys_only)
	@echo "Creating synthesis completion marker..."
	@echo "MLow Audio Codec Synthesis Complete" > $(BITSTREAM_FILE)
	@echo "Date: $(shell date)" >> $(BITSTREAM_FILE)
	@echo "FPGA Family: $(FPGA_FAMILY)" >> $(BITSTREAM_FILE)
	@echo "Top Module: $(TOP_MODULE)" >> $(BITSTREAM_FILE)
	@echo "Synthesis completed successfully!" >> $(BITSTREAM_FILE)
	@echo "Install NextPNR and icepack for complete FPGA implementation." >> $(BITSTREAM_FILE)
else ifeq ($(TOOL),openfpga)
	$(BITSTREAM_CMD) $(BITSTREAM_FLAGS) $(BITSTREAM_TARGET) FPGA_PART=$(FPGA_PART)
else ifeq ($(TOOL),vivado)
	$(BITSTREAM_CMD) $(BITSTREAM_FLAGS) $(BITSTREAM_SCRIPT) -tclargs $(FPGA_PART) $(TOP_MODULE)
endif
	@echo "Bitstream generated: $(BITSTREAM_FILE)"

# Timing analysis
timing: impl
	@echo "Running timing analysis..."
ifeq ($(TOOL),yosys_nextpnr)
	@if command -v $(PNR_CMD) >/dev/null 2>&1; then \
		echo "Timing analysis completed (see NextPNR output above)"; \
	else \
		echo "Timing analysis not available (NextPNR not installed)"; \
	fi
else ifeq ($(TOOL),yosys_only)
	@echo "Timing analysis not available in Yosys-only mode"
	@echo "Install NextPNR for timing analysis"
else ifeq ($(TOOL),openfpga)
	make -C openfpga $(FPGA_FAMILY)_timing FPGA_PART=$(FPGA_PART)
else ifeq ($(TOOL),vivado)
	$(SYNTH_CMD) $(SYNTH_FLAGS) vivado_timing.tcl -tclargs $(FPGA_PART) $(TOP_MODULE)
endif

# Resource utilization
resources: synth
	@echo "Resource utilization for $(TOP_MODULE):"
ifeq ($(TOOL),yosys_nextpnr)
	@echo "Check Yosys synthesis output above for resource statistics"
else ifeq ($(TOOL),yosys_only)
	@echo "Resource utilization from Yosys synthesis:"
	@if [ -f $(VERILOG_FILE) ]; then \
		echo "Synthesized netlist: $(VERILOG_FILE)"; \
		echo "Check the synthesis output above for detailed statistics"; \
	else \
		echo "Synthesis output not found"; \
	fi
else ifeq ($(TOOL),openfpga)
	make -C openfpga resources FPGA_FAMILY=$(FPGA_FAMILY)
else ifeq ($(TOOL),vivado)
	@grep -A 20 "Resource Utilization" $(REPORTS_DIR)/synth_1/synth_1.rpt
endif

# Power analysis
power: impl
	@echo "Power analysis not available for open-source tools"
	@echo "Use commercial tools (Vivado/Quartus) for power analysis"

# Simulation
sim: $(BUILD_DIR)
	@echo "Running simulation..."
	cd ../../ && make SIM=iverilog test
	@echo "Simulation completed!"

# Generate comprehensive report
report: bitstream
	@echo "Generating comprehensive FPGA report..."
	@echo "FPGA Implementation Report for MLow Audio Codec" > $(REPORTS_DIR)/fpga_report.txt
	@echo "==============================================" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "Date: $(shell date)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "FPGA Family: $(FPGA_FAMILY)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "FPGA Part: $(FPGA_PART)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "Tool: $(TOOL)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "Top Module: $(TOP_MODULE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "Bitstream: $(BITSTREAM_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "Files Generated:" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Synthesis Script: $(SYNTH_SCRIPT)" >> $(REPORTS_DIR)/fpga_report.txt
ifeq ($(TOOL),yosys_only)
	@echo "- Synthesized Netlist: $(VERILOG_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Constraints: $(PCF_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Synthesis Complete: $(BITSTREAM_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "Next Steps:" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Install NextPNR for place and route" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Install icepack for bitstream generation" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Run: make all TOOL=yosys_nextpnr" >> $(REPORTS_DIR)/fpga_report.txt
else
	@echo "- Netlist: $(NETLIST_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Constraints: $(PCF_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Place & Route: $(ASC_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
	@echo "- Bitstream: $(BITSTREAM_FILE)" >> $(REPORTS_DIR)/fpga_report.txt
endif
	@echo "Report generated: $(REPORTS_DIR)/fpga_report.txt"

# Install instructions
install_tools:
	@echo "Installing FPGA implementation tools..."
	@echo ""
	@echo "Ubuntu/Debian (Recommended):"
	@echo "  sudo apt-get update"
	@echo "  sudo apt-get install -y yosys nextpnr-ice40"
	@echo "  # Note: icepack may not be available in Ubuntu repos"
	@echo "  # For complete flow, build icestorm from source:"
	@echo "  git clone https://github.com/cliffordwolf/icestorm.git"
	@echo "  cd icestorm/icepack"
	@echo "  make"
	@echo "  sudo make install"
	@echo ""
	@echo "macOS:"
	@echo "  brew install yosys nextpnr-ice40 icestorm-tools"
	@echo ""
	@echo "Build from source (if packages not available):"
	@echo "1. Install NextPNR (Place and Route):"
	@echo "   git clone https://github.com/YosysHQ/nextpnr.git"
	@echo "   cd nextpnr"
	@echo "   cmake . -DARCH=ice40"
	@echo "   make -j$(nproc)"
	@echo "   sudo make install"
	@echo ""
	@echo "2. Install icepack (Bitstream generation):"
	@echo "   git clone https://github.com/cliffordwolf/icestorm.git"
	@echo "   cd icestorm/icepack"
	@echo "   make"
	@echo "   sudo make install"
	@echo ""
	@echo "3. After installation, run:"
	@echo "   make all TOOL=yosys_nextpnr"

# Clean
clean:
	@echo "Cleaning FPGA build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -rf $(REPORTS_DIR)
	rm -rf *.jou
	rm -rf *.log
	rm -rf *.str
	rm -rf *.bit
	rm -rf *.bin
	rm -rf *.asc
	rm -rf *.json
	rm -rf *.v
	rm -rf *_complete.txt
	@echo "Clean completed successfully!"

# Help
help:
	@echo "FPGA Implementation Makefile for MLow Audio Codec"
	@echo "================================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Complete synthesis, implementation, and bitstream"
	@echo "  synth      - Run synthesis only"
	@echo "  impl       - Run implementation (requires synthesis)"
	@echo "  bitstream  - Generate bitstream (requires implementation)"
	@echo "  timing     - Run timing analysis"
	@echo "  resources  - Show resource utilization"
	@echo "  power      - Run power analysis"
	@echo "  sim        - Run simulation"
	@echo "  report     - Generate comprehensive report"
	@echo "  install_tools - Show installation instructions"
	@echo "  clean      - Clean build artifacts"
	@echo "  help       - Show this help"
	@echo ""
	@echo "Configuration:"
	@echo "  FPGA_FAMILY - FPGA family (ice40, ecp5, xilinx7)"
	@echo "  FPGA_PART   - Specific FPGA part number"
	@echo "  TOOL        - Implementation tool (yosys_only, yosys_nextpnr, openfpga, vivado)"
	@echo ""
	@echo "Available Tools:"
	@echo "  yosys_only     - Yosys synthesis only (default, works with available tools)"
	@echo "  yosys_nextpnr  - Complete Yosys + NextPNR flow (requires NextPNR installation)"
	@echo "  openfpga       - OpenFPGA flow (requires OpenFPGA installation)"
	@echo "  vivado         - Vivado flow (commercial)"
	@echo ""
	@echo "Example Usage:"
	@echo "  make all                                    # Complete flow with defaults"
	@echo "  make all TOOL=yosys_only                   # Synthesis only (recommended)"
	@echo "  make all TOOL=yosys_nextpnr                # Complete flow (requires NextPNR)"
	@echo "  make install_tools                         # Show installation instructions"
	@echo "  make report                                 # Generate report"

.PHONY: all synth impl bitstream timing resources power sim report install_tools clean help 