# MLow Codec Architecture and Design Specification

**Version:** 1.0.0  
**Date:** 2025-08-03T03:00:00Z  
**Author:** Vyges Team  
**IP:** vyges/mlow-codec  

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Core Components](#core-components)
4. [Data Flow](#data-flow)
5. [Interface Specifications](#interface-specifications)
6. [Performance Requirements](#performance-requirements)
7. [Implementation Details](#implementation-details)
8. [Verification Strategy](#verification-strategy)

## Overview

MLow is Meta's low-bitrate audio codec designed for real-time communication (RTC) applications. This implementation provides:

- **2x better quality** than Opus at 6kbps (POLQA MOS 3.9 vs 1.89)
- **10% lower computational complexity** than Opus
- **Split-band CELP architecture** with SuperWideBand support
- **Bitrate range:** 6-32 kbps
- **Bandwidth support:** NarrowBand (8kHz), WideBand (16kHz), SuperWideBand (32kHz)
- **Enhanced frame buffering** with full frame bus interface
- **Formal verification** with basic assertion-based checks

### Implementation Versions

This IP provides two implementation versions:

#### 1. **Full SystemVerilog Implementation** (Reference Design)
- Complete MLow codec with all advanced features
- SystemVerilog assertions and coverage
- Advanced verification features
- Requires commercial simulators (ModelSim, VCS, Xcelium)

#### 2. **Simplified Icarus Verilog Implementation** (Current Working Version)
- Streamlined implementation for open-source tools
- Icarus Verilog compatible
- Core functionality preserved
- Suitable for FPGA and ASIC synthesis
- Enhanced with frame buffering and formal verification

### Key Features

- Split-band processing for efficient compression
- Advanced excitation generation and parameter quantization
- Range encoding for optimal bitstream compression
- Forward Error Correction (FEC) support
- Real-time encoding/decoding with low latency
- Enhanced frame buffering with array-based storage
- Full frame bus interface with dedicated handshake signals
- Basic formal verification with assertion-based checks

## System Architecture

### 1. Full SystemVerilog Implementation Architecture

#### Top-Level Block Diagram (Reference Design)

```
┌─────────────────────────────────────────────────────────────┐
│                    MLow Codec Core                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Audio     │  │   Control   │  │   Packet    │         │
│  │ Interface   │  │ Interface   │  │ Interface   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│         │                │                │                │
│         ▼                ▼                ▼                │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Frame Buffer & Control                     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Mode Selection Logic                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │    Encoder      │  │    Decoder      │                  │
│  │   Pipeline      │  │   Pipeline      │                  │
│  └─────────────────┘  └─────────────────┘                  │
│         │                       │                          │
│         ▼                       ▼                          │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Range Encoder/Decoder                      │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2. Simplified Icarus Verilog Implementation Architecture

#### Top-Level Block Diagram (Current Working Version)

```
┌─────────────────────────────────────────────────────────────┐
│                MLow Codec Core (Simplified)                 │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Audio     │  │   Control   │  │   Packet    │         │
│  │ Interface   │  │ Interface   │  │ Interface   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│         │                │                │                │
│         ▼                ▼                ▼                │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Audio Interface Module                     │ │
│  │              (Enhanced Frame Buffer & Flow Control)     │ │
│  │              - Array-based frame storage                │ │
│  │              - Full frame bus interface                 │ │
│  │              - Frame handshake protocol                 │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Blackbox Processing Modules               │ │
│  │              - mlow_encoder.sv (placeholder)           │ │
│  │              - mlow_decoder.sv (placeholder)           │ │
│  │              - packet_framer.sv (placeholder)          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Range Codec (Simplified)                   │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### Enhanced Architecture Features

**Design Philosophy:**
- **Compatibility First**: Optimized for Icarus Verilog and open-source tools
- **Core Functionality**: Preserves essential MLow codec features
- **Synthesis Ready**: Suitable for FPGA and ASIC implementation
- **Verification Friendly**: Enhanced with formal verification and comprehensive testing
- **Frame Buffering**: Advanced array-based frame storage with full bus interface

**Key Enhancements:**
- Enhanced frame buffering with array-based storage
- Full frame bus interface with dedicated handshake signals
- Blackbox module placeholders for future implementation
- Basic formal verification with assertion-based checks
- Comprehensive test coverage with 12 test categories
- 16-sample frame testing for quick simulation

### Core Architecture Components

#### Full SystemVerilog Implementation Components

1. **Audio Interface Module** - Handles PCM audio input/output
2. **Control Interface Module** - Manages encoding/decoding modes and parameters
3. **Packet Interface Module** - Handles compressed bitstream I/O
4. **Frame Buffer** - Stores audio samples for processing
5. **Mode Selection Logic** - Routes data between encoder/decoder
6. **Split-Band Processor** - Implements frequency domain splitting
7. **CELP Encoder** - Implements Code Excited Linear Prediction encoding
8. **CELP Decoder** - Implements Code Excited Linear Prediction decoding
9. **Range Encoder/Decoder** - Handles bitstream compression/decompression

#### Simplified Implementation Components

1. **Audio Interface Module** (`audio_interface.sv`) - Enhanced PCM audio handling with frame buffering
2. **MLow Codec Core** (`mlow_codec.sv`) - Integrated processing with blackbox modules
3. **Blackbox Modules**:
   - `mlow_encoder.sv` - Placeholder encoder implementation
   - `mlow_decoder.sv` - Placeholder decoder implementation
   - `packet_framer.sv` - Placeholder packet framing implementation
4. **Formal Verification**:
   - `verification_checks.sv` - Basic assertion-based verification
   - `formal_testbench.sv` - Formal verification testbench
5. **Control Interface** - Embedded within main module
6. **Packet Interface** - Simplified bitstream handling
7. **Enhanced Frame Buffer** - Array-based storage with full bus interface

## Core Components

### Full SystemVerilog Implementation Components

#### 1. Audio Interface Module (`audio_interface.sv`)

**Purpose:** Manages PCM audio data input/output with flow control

**Key Features:**
- 16-bit PCM audio handling
- Configurable sample rates (8kHz-48kHz)
- Flow control with ready/valid handshaking
- Frame-based processing support
- Advanced state machine with multiple processing states

**Interface:**
```systemverilog
module audio_interface (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Audio Input
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    
    // Audio Output  
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Internal Interface
    output logic [15:0] frame_data_o,
    output logic        frame_valid_o,
    input  logic        frame_ready_i,
    
    input  logic [15:0] decoded_data_i,
    input  logic        decoded_valid_i,
    output logic        decoded_ready_o
);
```

### Simplified Icarus Verilog Implementation Components

#### 1. Enhanced Audio Interface Module (`audio_interface.sv`)

**Purpose:** Enhanced PCM audio data handling with integrated frame buffering and full frame bus interface

**Key Features:**
- 16-bit PCM audio handling
- Array-based frame buffer management (`frame_buffer[0:FRAME_SIZE-1]`)
- Full frame bus interface (`frame_data_bus_o[0:FRAME_SIZE-1]`)
- Frame handshake protocol (`frame_bus_valid_o`, `frame_bus_ready_i`)
- Backward compatibility with `frame_data_o`
- Simplified state machine (5 states vs 8+ in full version)
- Ready/valid handshaking
- Icarus Verilog compatible syntax

**Interface:**
```systemverilog
module audio_interface (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // External audio interface
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Internal frame interface (backward compatible)
    output logic [15:0] frame_data_o,
    output logic        frame_valid_o,
    input  logic        frame_ready_i,
    
    // Enhanced full frame bus interface
    output logic [15:0] frame_data_bus_o [0:FRAME_SIZE-1],
    output logic        frame_bus_valid_o,
    input  logic        frame_bus_ready_i
);
```

**Enhanced Features:**
- **Array-based Frame Buffer**: Complete frame storage in `frame_buffer[0:FRAME_SIZE-1]`
- **Full Frame Bus Interface**: Parallel access to all frame samples
- **Frame Handshake Protocol**: Dedicated valid/ready signals for frame bus
- **Backward Compatibility**: `frame_data_o` maintains existing interface compatibility
- **Enhanced Testing**: Support for 16-sample frames for quick simulation

#### 2. MLow Codec Core (`mlow_codec.sv`)

**Purpose:** Integrated MLow codec with blackbox modules and enhanced processing pipeline

**Key Features:**
- Unified module combining all processing stages
- Blackbox module instantiations for encoder, decoder, and packet framer
- Bitrate configuration table (6-32 kbps)
- Mode control (encode/decode)
- Status monitoring
- Enhanced frame interface connections

**Interface:**
```systemverilog
module mlow_codec (
    // Clock and Reset
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Audio Interface
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Control Interface
    input  logic        encode_mode_i,
    input  logic [3:0]  bitrate_sel_i,
    input  logic [1:0]  bandwidth_sel_i,
    
    // Packet Interface
    inout  logic [7:0]  packet_data_io,
    output logic        packet_valid_o,
    input  logic        packet_ready_i,
    output logic        packet_start_o,
    output logic        packet_end_o,
    
    // Status Interface
    output logic        busy_o,
    output logic        error_o,
    output logic [7:0]  quality_metric_o
);
```

**Enhanced Processing Pipeline:**
- **Audio Interface Integration**: Direct connection to enhanced audio interface
- **Blackbox Encoder**: `mlow_encoder.sv` placeholder with pass-through logic
- **Blackbox Decoder**: `mlow_decoder.sv` placeholder with pass-through logic
- **Blackbox Packet Framer**: `packet_framer.sv` placeholder with basic framing
- **Range Codec**: Basic bitstream handling
- **Control Logic**: Simplified mode and parameter management
- **Enhanced Frame Interface**: Full frame bus connections

#### 3. Blackbox Modules

**MLow Encoder** (`mlow_encoder.sv`):
```systemverilog
module mlow_encoder (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Audio input
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    
    // Encoded output
    output logic [15:0] encoded_data_o,
    output logic        encoded_valid_o,
    input  logic        encoded_ready_i,
    
    // Control
    input  logic [3:0]  bitrate_sel_i,
    input  logic [1:0]  bandwidth_sel_i,
    
    // Status
    output logic        busy_o,
    output logic        error_o,
    output logic [7:0]  quality_metric_o
);
```

**MLow Decoder** (`mlow_decoder.sv`):
```systemverilog
module mlow_decoder (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Encoded input
    input  logic [15:0] encoded_data_i,
    input  logic        encoded_valid_i,
    output logic        encoded_ready_o,
    
    // Audio output
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Control
    input  logic [3:0]  bitrate_sel_i,
    input  logic [1:0]  bandwidth_sel_i,
    
    // Status
    output logic        busy_o,
    output logic        error_o
);
```

**Packet Framer** (`packet_framer.sv`):
```systemverilog
module packet_framer (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Data input
    input  logic [15:0] data_i,
    input  logic        data_valid_i,
    output logic        data_ready_o,
    
    // Packet output
    output logic [7:0]  packet_data_o,
    output logic        packet_valid_o,
    input  logic        packet_ready_i,
    output logic        packet_start_o,
    output logic        packet_end_o,
    
    // Status
    output logic        busy_o,
    output logic        error_o,
    output logic [15:0] packet_count_o
);
```

#### 4. Formal Verification Components

**Verification Checks** (`verification_checks.sv`):
- Frame integrity checks (4 categories)
- Handshake protocol checks (4 categories)
- Error handling checks (3 categories)
- Flow control checks (2 categories)
- Coverage monitoring for frame transfers, backpressure, errors, and packet transfers

**Formal Testbench** (`formal_testbench.sv`):
- Integration testbench for formal verification
- DUT instantiation with verification checks
- Basic stimulus generation
- Waveform generation support

## Implementation Comparison

### Feature Comparison Matrix

| Feature | Full SystemVerilog | Simplified Icarus |
|---------|-------------------|-------------------|
| **Simulator Support** | Commercial (ModelSim, VCS, Xcelium) | Open-source (Icarus, Verilator) |
| **SystemVerilog Features** | Full (assertions, covergroups, etc.) | Basic (no assertions/covergroups) |
| **Module Count** | 8+ separate modules | 2 integrated modules + 3 blackbox |
| **State Machine Complexity** | Advanced (8+ states) | Simplified (5 states) |
| **Verification Features** | Comprehensive | Basic functional + formal verification |
| **Frame Buffering** | Basic | Enhanced array-based with full bus interface |
| **Formal Verification** | Advanced SVA | Basic assertion-based checks |
| **Synthesis Readiness** | Requires commercial tools | FPGA/ASIC ready |
| **Development Complexity** | High | Low |
| **Maintenance** | Complex | Simple |

### Use Case Recommendations

#### **Full SystemVerilog Implementation**
- **When to use**: Advanced verification, commercial development
- **Target**: High-end ASIC development, comprehensive testing
- **Tools**: Commercial simulators, advanced verification tools
- **Team**: Experienced SystemVerilog developers

#### **Simplified Icarus Implementation**
- **When to use**: Open-source development, rapid prototyping, educational purposes
- **Target**: FPGA implementation, educational purposes, enhanced frame buffering
- **Tools**: Icarus Verilog, Verilator, open-source tools
- **Team**: Mixed experience levels, open-source community
- **Features**: Enhanced frame buffering, formal verification, blackbox modules

### 2. Split-Band Processor (`split_band_processor.sv`)

**Purpose:** Implements frequency domain splitting for efficient compression

**Architecture:**
- **Low Band:** 0-4kHz (NarrowBand), 0-8kHz (WideBand)
- **High Band:** 4-8kHz (WideBand), 8-16kHz (SuperWideBand)

**Key Features:**
- Quadrature Mirror Filter (QMF) bank
- Adaptive subband allocation
- Shared information exploitation between bands

```systemverilog
module split_band_processor (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Input
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    
    // Low Band Output
    output logic [15:0] low_band_data_o,
    output logic        low_band_valid_o,
    input  logic        low_band_ready_i,
    
    // High Band Output
    output logic [15:0] high_band_data_o,
    output logic        high_band_valid_o,
    input  logic        high_band_ready_i,
    
    // Control
    input  logic [1:0]  bandwidth_sel_i
);
```

### 3. CELP Encoder (`celp_encoder.sv`)

**Purpose:** Implements Code Excited Linear Prediction encoding

**Components:**
- **LPC Analysis:** Linear Predictive Coding coefficient calculation
- **Pitch Analysis:** Pitch period and gain estimation
- **Codebook Search:** Optimal excitation vector selection
- **Parameter Quantization:** Efficient parameter encoding

```systemverilog
module celp_encoder (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Audio Input
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    
    // Encoded Output
    output logic [7:0]  encoded_data_o,
    output logic        encoded_valid_o,
    input  logic        encoded_ready_i,
    
    // Control
    input  logic [3:0]  bitrate_sel_i,
    input  logic [1:0]  bandwidth_sel_i,
    
    // Status
    output logic        busy_o,
    output logic [7:0]  quality_metric_o
);
```

### 4. CELP Decoder (`celp_decoder.sv`)

**Purpose:** Implements Code Excited Linear Prediction decoding

**Components:**
- **Parameter Decoding:** Bitstream parameter extraction
- **Excitation Generation:** Synthesis of excitation signal
- **LPC Synthesis:** Audio reconstruction using LPC coefficients
- **Post-processing:** Audio enhancement and filtering

```systemverilog
module celp_decoder (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Encoded Input
    input  logic [7:0]  encoded_data_i,
    input  logic        encoded_valid_i,
    output logic        encoded_ready_o,
    
    // Audio Output
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Control
    input  logic [3:0]  bitrate_sel_i,
    input  logic [1:0]  bandwidth_sel_i,
    
    // Status
    output logic        busy_o,
    output logic        error_o
);
```

### 5. Range Encoder/Decoder (`range_codec.sv`)

**Purpose:** Implements arithmetic coding for optimal bitstream compression

**Features:**
- Adaptive probability modeling
- Context-based encoding
- Error resilience mechanisms
- Configurable precision

```systemverilog
module range_codec (
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Encode Interface
    input  logic [7:0]  encode_data_i,
    input  logic        encode_valid_i,
    output logic        encode_ready_o,
    
    // Decode Interface
    output logic [7:0]  decode_data_o,
    output logic        decode_valid_o,
    input  logic        decode_ready_i,
    
    // Packet Interface
    output logic [7:0]  packet_data_o,
    output logic        packet_valid_o,
    input  logic        packet_ready_i,
    
    // Control
    input  logic        encode_mode_i
);
```

## Data Flow

### Enhanced Encoding Flow

1. **Audio Input:** PCM samples arrive via audio interface
2. **Enhanced Frame Buffering:** Samples accumulated into array-based frame buffer
3. **Full Frame Bus Interface:** Complete frame available via frame bus
4. **Frame Handshake Protocol:** Frame transfer via dedicated valid/ready signals
5. **Blackbox Processing:** Encoder, decoder, and packet framer processing
6. **Range Encoding:** Final bitstream compression
7. **Packet Output:** Compressed data output via packet interface

### Enhanced Decoding Flow

1. **Packet Input:** Compressed bitstream received
2. **Range Decoding:** Arithmetic decoding of bitstream
3. **Blackbox Processing:** Decoder and packet framer processing
4. **Parameter Extraction:** Decode LPC, pitch, and excitation parameters
5. **Excitation Synthesis:** Generate excitation signal
6. **LPC Synthesis:** Reconstruct audio using LPC coefficients
7. **Enhanced Frame Buffering:** Array-based frame storage for output
8. **Full Frame Bus Interface:** Complete frame available for output
9. **Audio Output:** PCM samples output via audio interface

## Interface Specifications

### Clock and Reset

- **Clock:** Single clock domain design
- **Reset:** Active-low asynchronous reset
- **Frequency:** Configurable (typically 48MHz for 48kHz audio)

### Enhanced Audio Interface

- **Data Width:** 16-bit signed PCM
- **Sample Rate:** 8kHz, 16kHz, 32kHz, 48kHz configurable
- **Flow Control:** Ready/valid handshaking
- **Frame Size:** Configurable (16-960 samples, 16 for quick testing)
- **Frame Buffer:** Array-based storage with full frame bus interface
- **Frame Handshake:** Dedicated bus valid/ready signals

### Control Interface

- **Encode/Decode Mode:** Single bit control
- **Bitrate Selection:** 4-bit field (6-32 kbps)
- **Bandwidth Selection:** 2-bit field (NB/WB/SWB)

### Packet Interface

- **Data Width:** 8-bit packet data
- **Flow Control:** Ready/valid handshaking
- **Packet Markers:** Start/end packet indicators

## Performance Requirements

### Latency

- **Encoding Latency:** ≤ 20ms
- **Decoding Latency:** ≤ 15ms
- **End-to-End Latency:** ≤ 35ms

### Throughput

- **Maximum Sample Rate:** 48kHz
- **Maximum Bitrate:** 32 kbps
- **Frame Processing:** Real-time capability
- **Enhanced Frame Processing:** 16-sample frames for quick testing

### Quality Metrics

- **POLQA MOS:** 3.9 at 6kbps (2x better than Opus)
- **Bandwidth Support:** NB (8kHz), WB (16kHz), SWB (32kHz)
- **Packet Loss Resilience:** FEC support for 30% packet loss

### Resource Utilization

- **Estimated Gates:** 50,000 gates
- **Memory:** 8KB RAM, 4KB ROM
- **Power:** 5mW typical, 15mW maximum

## Implementation Details

### Memory Organization

```
┌─────────────────────────────────────────────────────────────┐
│                    Memory Map                               │
├─────────────────────────────────────────────────────────────┤
│ 0x0000-0x0FFF │ Frame Buffer (4KB) - Array-based storage   │
│ 0x1000-0x1FFF │ LPC Coefficients (4KB)                     │
│ 0x2000-0x2FFF │ Codebook Storage (4KB)                     │
│ 0x3000-0x3FFF │ Range Coder State (4KB)                    │
│ 0x4000-0x4FFF │ FEC Buffer (4KB)                           │
│ 0x5000-0x5FFF │ Reserved                                    │
│ 0x6000-0x6FFF │ Control Registers (4KB)                    │
│ 0x7000-0x7FFF │ Status Registers (4KB)                     │
└─────────────────────────────────────────────────────────────┘
```

### Pipeline Stages

**Enhanced Encoder Pipeline:**
1. **Stage 1:** Enhanced frame buffering and pre-processing
2. **Stage 2:** Full frame bus interface and handshake
3. **Stage 3:** Blackbox encoder processing
4. **Stage 4:** Range encoding and packet formation

**Enhanced Decoder Pipeline:**
1. **Stage 1:** Packet reception and range decoding
2. **Stage 2:** Blackbox decoder processing
3. **Stage 3:** Enhanced frame buffering for output
4. **Stage 4:** Full frame bus interface for output

### Configuration Parameters

```systemverilog
// Default configuration
parameter int SAMPLE_RATE = 48000;
parameter int FRAME_SIZE = 16;        // 16-sample frames for quick testing
parameter int MAX_BITRATE = 32000;
parameter int LPC_ORDER = 16;
parameter int SUBBAND_COUNT = 2;

// Bitrate configuration table
typedef struct packed {
    logic [3:0] bitrate_sel;
    logic [15:0] target_bitrate;
    logic [7:0] quality_target;
} bitrate_config_t;

bitrate_config_t bitrate_configs[16] = '{
    {4'h0, 16'd6000, 8'd60},   // 6 kbps
    {4'h1, 16'd8000, 8'd65},   // 8 kbps
    {4'h2, 16'd12000, 8'd70},  // 12 kbps
    {4'h3, 16'd16000, 8'd75},  // 16 kbps
    {4'h4, 16'd20000, 8'd80},  // 20 kbps
    {4'h5, 16'd24000, 8'd85},  // 24 kbps
    {4'h6, 16'd28000, 8'd90},  // 28 kbps
    {4'h7, 16'd32000, 8'd95},  // 32 kbps
    // ... additional configurations
    default: {4'h0, 16'd6000, 8'd60}
};
```

## Verification Strategy

### Enhanced Testbench Architecture

1. **Test Harness:** Top-level testbench with comprehensive testing
2. **Reference Model:** Software reference implementation
3. **Test Vectors:** Standard audio test files and synthetic signals
4. **Coverage:** Functional and code coverage metrics
5. **Formal Verification:** Basic assertion-based verification
6. **Cocotb Integration:** Python-based verification with advanced test scenarios

### Enhanced Test Scenarios

1. **Functional Tests:**
   - Encoding/decoding at all supported bitrates
   - All bandwidth modes (NB/WB/SWB)
   - Frame boundary conditions
   - Error handling and recovery
   - Enhanced frame buffering verification

2. **Enhanced Frame Tests:**
   - Complete frame collection verification
   - Partial frame handling verification
   - Frame boundary detection verification
   - Full frame bus interface testing

3. **Performance Tests:**
   - Latency measurements
   - Throughput verification
   - Quality metrics validation
   - Resource utilization
   - 16-sample frame processing performance

4. **Formal Verification Tests:**
   - Frame integrity assertions
   - Handshake protocol verification
   - Error condition monitoring
   - Flow control validation

5. **Cocotb Tests:**
   - Python-based test scenarios
   - Advanced async/await test sequences
   - Quality metric calculation and POLQA MOS estimation
   - Performance profiling and analysis
   - End-to-end verification cycles

6. **Stress Tests:**
   - Maximum bitrate operation
   - Packet loss scenarios
   - Continuous operation
   - Power consumption

### Verification Tools

- **Simulation:** Verilator, Icarus Verilog
- **Coverage:** Verilator coverage, functional coverage
- **Formal:** Basic assertion-based verification
- **Linting:** Verible for code quality
- **Cocotb:** Python-based verification framework

### Quality Assurance

- **POLQA Testing:** Automated quality measurement
- **Bit-exact Verification:** Against reference implementation
- **Interoperability:** Testing with other codecs
- **Regression Testing:** Automated test suite execution
- **Formal Verification:** Basic assertion-based verification
- **Cocotb Verification:** Python-based comprehensive testing

---

*This specification follows Vyges conventions for hardware IP development and provides a complete foundation for implementing the MLow audio codec with enhanced frame buffering and formal verification capabilities.*
