#=============================================================================
# OpenLane Configuration for MLow Audio Codec IP
#=============================================================================
# Description: Configuration file for ASIC synthesis and place-and-route
#              using OpenLane flow with multiple PDKs
# Author:      Vyges IP Development Team
# Date:        2025-01-27
# License:     Apache-2.0
#=============================================================================

# Design configuration
set ::env(DESIGN_NAME) "mlow_codec"
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1

# Clock configuration
set ::env(CLOCK_PERIOD) "1.0"  # 1GHz for 130nm processes
set ::env(CLOCK_PORT) "clk_i"
set ::env(CLOCK_NET) "clk_i"

# Synthesis configuration
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(SYNTH_MAX_FANOUT) 20
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 0
set ::env(SYNTH_OPT) 0

# Floorplan configuration
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 1000 1000"  # 1mm x 1mm die
set ::env(PLACE_PINS_ARGS) "-random"
set ::env(FP_PIN_ORDER_CFG) "pin_order.cfg"

# Placement configuration
set ::env(PL_TARGET_DENSITY) 0.65
set ::env(PL_TIME_DRIVEN) 1

# Clock tree synthesis
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2"
set ::env(CTS_ROOT_BUFFER) "sky130_fd_sc_hd__clkbuf_16"
set ::env(CTS_MAX_CAP) 2.0

# Routing configuration
set ::env(ROUTING_STRATEGY) 0
set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_ADJUSTMENT) 0.15
set ::env(GLB_RT_L1_ADJUSTMENT) 0.99
set ::env(GLB_RT_L2_ADJUSTMENT) 0.99

# Power configuration
set ::env(FP_PDN_MACRO_HOOKS) "mlow_codec vccd1 vssd1 vccd1 vssd1"
set ::env(VDD_NETS) "vccd1"
set ::env(GND_NETS) "vssd1"

# LVS configuration
set ::env(LVS_CONNECT_BY_LABEL) 0
set ::env(LVS_INSERT_POWER_PINS) 1

# DRC configuration
set ::env(QUIT_ON_DRC) 0
set ::env(QUIT_ON_LVS_ERROR) 0
set ::env(QUIT_ON_MAGIC_DRC) 0

# Verification configuration
set ::env(RUN_KLAYOUT) 1
set ::env(RUN_KLAYOUT_DRC) 0
set ::env(KLAYOUT_DRC_KLAYOUT_GDS) 0

# Reports configuration
set ::env(REPORTS_DIR) "reports"
set ::env(LOG_DIR) "logs"
set ::env(RESULTS_DIR) "results"

# MLow-specific constraints
set ::env(SAMPLE_RATE) 48000
set ::env(FRAME_SIZE) 480
set ::env(MAX_BITRATE) 32000
set ::env(LPC_ORDER) 16
set ::env(SUBBAND_COUNT) 2

# Performance targets
set ::env(TARGET_FREQUENCY) 1000
set ::env(TARGET_AREA) 50000
set ::env(TARGET_POWER) 50 