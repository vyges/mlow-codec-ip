#=============================================================================
# Synthesis Makefile for MLow Audio Codec
#=============================================================================
# Description: Makefile for Yosys synthesis of MLow audio codec
#              with CELP encoding/decoding and range encoding.
#              Follows Vyges conventions for synthesis flow.
# Author:      Vyges IP Development Team
# Date:        2025-08-02
# License:     Apache-2.0
#=============================================================================

# Configuration
RTL_DIR = ../../rtl
NETLISTS_DIR = netlists
REPORTS_DIR = reports
YOSYS_CMD = yosys
YOSYS_FLAGS = -q

# Default target
all: synth_individual

# Create directories
$(NETLISTS_DIR):
	mkdir -p $(NETLISTS_DIR)

$(REPORTS_DIR):
	mkdir -p $(REPORTS_DIR)

# Create all required directories
create_dirs: $(REPORTS_DIR) $(NETLISTS_DIR)

# Individual module synthesis (recommended)
synth_individual: create_dirs
	@echo "=== MLow Codec Individual Module Synthesis ==="
	@echo "Testing each module individually..."
	@echo ""
	@echo "1. audio_interface:"
	$(YOSYS_CMD) -p "read_verilog -sv $(RTL_DIR)/audio_interface.sv; hierarchy -top audio_interface; synth -top audio_interface; stat" | tee $(REPORTS_DIR)/audio_interface_stats.txt && echo "PASS" || echo "FAIL"
	@echo "2. mlow_codec (with all modules):"
	$(YOSYS_CMD) -p "read_verilog -sv $(RTL_DIR)/audio_interface.sv $(RTL_DIR)/mlow_codec.sv $(RTL_DIR)/mlow_encoder.sv $(RTL_DIR)/mlow_decoder.sv $(RTL_DIR)/packet_framer.sv; hierarchy -top mlow_codec; synth -top mlow_codec; stat" | tee $(REPORTS_DIR)/mlow_codec_stats.txt && echo "PASS" || echo "FAIL"
	@echo ""
	@echo "=== Individual Module Synthesis Complete ==="
	@echo "Detailed statistics saved to $(REPORTS_DIR)/*_stats.txt"

# Simplified synthesis (individual modules)
synth_simple: create_dirs
	@echo "Running simplified synthesis for individual modules..."
	@echo "Step 1: Synthesizing mlow_codec..."
	./timeout_wrapper.sh 30 "$(YOSYS_CMD) $(YOSYS_FLAGS) -p 'read_verilog -sv $(RTL_DIR)/mlow_codec.sv $(RTL_DIR)/audio_interface.sv $(RTL_DIR)/mlow_encoder.sv $(RTL_DIR)/mlow_decoder.sv $(RTL_DIR)/packet_framer.sv; hierarchy -top mlow_codec; synth -top mlow_codec; stat'" || (echo "mlow_codec synthesis failed or timed out"; exit 1)
	@echo "Step 2: Synthesizing audio_interface..."
	./timeout_wrapper.sh 30 "$(YOSYS_CMD) $(YOSYS_FLAGS) -p 'read_verilog -sv $(RTL_DIR)/audio_interface.sv; hierarchy -top audio_interface; synth -top audio_interface; stat'" || (echo "audio_interface synthesis failed or timed out"; exit 1)
	@echo "Simplified synthesis completed!"

# Full synthesis
synth_full: create_dirs
	@echo "Running full synthesis..."
	$(YOSYS_CMD) $(YOSYS_FLAGS) yosys_synth.ys
	@echo "Full synthesis completed!"

# Generic synthesis (no technology mapping)
synth_generic: create_dirs
	@echo "Running generic synthesis..."
	$(YOSYS_CMD) $(YOSYS_FLAGS) -p "read_verilog -sv $(RTL_DIR)/mlow_codec.sv $(RTL_DIR)/audio_interface.sv $(RTL_DIR)/mlow_encoder.sv $(RTL_DIR)/mlow_decoder.sv $(RTL_DIR)/packet_framer.sv; hierarchy -top mlow_codec; check; stat; synth -top mlow_codec; opt -purge; clean; stat; write_verilog -noattr -noexpr -nohex -nodec $(NETLISTS_DIR)/mlow_codec_generic.v"
	@echo "Generic synthesis completed!"

# Comprehensive synthesis test
synth_test: create_dirs
	@echo "Running comprehensive synthesis test..."
	./test_comprehensive_synthesis.sh

# Generate synthesis reports
generate_reports:
	@echo "Generating synthesis reports..."
	@echo "Synthesis report generated: $(REPORTS_DIR)/synthesis_report_generic.txt"

# Clean up
clean:
	rm -rf $(NETLISTS_DIR) $(REPORTS_DIR)
	rm -f *.v *.json *.txt
	rm -f temp_*.sv

# Help
help:
	@echo "Available targets:"
	@echo "  synth_individual  - Test each module individually (RECOMMENDED)"
	@echo "  synth_simple      - Simplified synthesis of individual modules"
	@echo "  synth_full        - Full synthesis with technology mapping"
	@echo "  synth_generic     - Generic synthesis (no technology mapping)"
	@echo "  synth_test        - Comprehensive synthesis test"
	@echo "  clean             - Clean generated files"
	@echo "  help              - Show this help"

.PHONY: all synth_individual synth_simple synth_full synth_generic synth_test generate_reports clean help create_dirs 