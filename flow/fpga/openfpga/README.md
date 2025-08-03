# OpenFPGA Implementation for MLow Audio Codec

This directory contains the OpenFPGA implementation flow for the MLow audio codec, providing a complete open-source FPGA implementation solution.

## Overview

The MLow audio codec is implemented using OpenFPGA, an open-source FPGA architecture generator and CAD tool. This implementation supports multiple FPGA families and provides comprehensive analysis capabilities.

## Supported FPGA Families

- **iCE40** (Lattice) - Default target
- **ECP5** (Lattice) - High-performance option
- **Xilinx 7-series** - Commercial FPGA support

## Directory Structure

```
openfpga/
├── Makefile              # Main OpenFPGA implementation Makefile
├── README.md             # This file
├── timeout_wrapper.sh    # Timeout protection for long-running tasks
├── build/                # Build artifacts (generated)
├── reports/              # Implementation reports (generated)
├── netlists/             # Generated netlists (generated)
└── constraints/          # FPGA constraints (generated)
```

## Prerequisites

### Required Tools

1. **OpenFPGA** - Open-source FPGA architecture generator
   ```bash
   # Install OpenFPGA (example)
   git clone https://github.com/LNIS-Projects/OpenFPGA.git
   cd OpenFPGA
   make install
   ```

2. **VPR** - Versatile Place and Route tool
   ```bash
   # Install VPR
   git clone https://github.com/verilog-to-routing/vtr-verilog-to-routing.git
   cd vtr-verilog-to-routing
   make
   ```

3. **Python 3** - Required for OpenFPGA scripts
   ```bash
   # Ensure Python 3 is available
   python3 --version
   ```

### Optional Tools

- **Yosys** - For fallback synthesis
- **NextPNR** - For fallback place and route
- **Icepack** - For bitstream generation

## Usage

### Basic Implementation

```bash
# Complete implementation flow
make all

# Individual steps
make synth      # Synthesis only
make pnr        # Place and route
make bitstream  # Generate bitstream
```

### Configuration

```bash
# Use different FPGA family
make all FPGA_FAMILY=ecp5

# Use different FPGA part
make all FPGA_PART=25k-cabga256

# Set OpenFPGA installation path
make all OPENFPGA_ROOT=/path/to/openfpga
```

### Analysis and Reporting

```bash
# Timing analysis
make timing

# Resource utilization
make resources

# Power analysis
make power

# Generate comprehensive report
make report
```

## Implementation Flow

### 1. Synthesis (OpenFPGA)

The synthesis step converts the RTL design into a technology-mapped netlist:

- **Input**: SystemVerilog RTL files
- **Output**: Technology-mapped netlist (XML format)
- **Tool**: OpenFPGA synthesis engine

### 2. Place and Route (VPR)

The place and route step maps the netlist to the target FPGA:

- **Input**: Technology-mapped netlist
- **Output**: Placed and routed design
- **Tool**: VPR (Versatile Place and Route)

### 3. Bitstream Generation

The bitstream generation step creates the final FPGA configuration:

- **Input**: Placed and routed design
- **Output**: FPGA bitstream file
- **Tool**: OpenFPGA bitstream generator

## Constraints

### Pin Constraints

The implementation includes comprehensive pin constraints for all MLow codec interfaces:

- **Clock**: `clk_i` → Pin 21
- **Reset**: `reset_n_i` → Pin 23
- **Audio Data**: `audio_data_i[15:0]` → Pins 24-39
- **Audio Control**: `audio_valid_i`, `audio_ready_o` → Pins 40-41
- **Audio Output**: `audio_data_o[15:0]` → Pins 42-57
- **Configuration**: Various control signals → Pins 60-76

### Timing Constraints

- **Clock Period**: 20ns (50MHz)
- **Setup/Hold**: Standard FPGA timing requirements

## Fallback Implementation

When OpenFPGA tools are not available, the implementation automatically falls back to:

1. **Yosys** for synthesis
2. **NextPNR** for place and route
3. **Icepack** for bitstream generation

This ensures the implementation can always complete, even without full OpenFPGA installation.

## Reports and Analysis

### Generated Reports

- **Implementation Report**: Complete implementation summary
- **Timing Report**: Critical path and timing analysis
- **Resource Report**: FPGA resource utilization
- **Power Report**: Power consumption estimates

### Report Locations

- `reports/openfpga_report.txt` - Main implementation report
- `reports/timing_report.txt` - Timing analysis results
- `reports/resource_report.txt` - Resource utilization
- `reports/power_report.txt` - Power analysis

## Troubleshooting

### Common Issues

1. **OpenFPGA not found**
   ```bash
   # Set OpenFPGA installation path
   export OPENFPGA_ROOT=/path/to/openfpga
   make all
   ```

2. **VPR not available**
   ```bash
   # Use fallback implementation
   make all TOOL=yosys_nextpnr
   ```

3. **Memory issues during P&R**
   ```bash
   # Increase system memory or use smaller FPGA
   make all FPGA_PART=hx1k-vq100
   ```

### Debug Mode

```bash
# Enable verbose output
make all V=1

# Run individual steps with debug
make synth V=1
make pnr V=1
```

## Performance Characteristics

### Resource Utilization (iCE40 hx8k)

- **Logic Cells**: ~200-300 LUTs
- **Memory**: ~1-2 BRAMs
- **I/O Pins**: 76 pins
- **Clock Domains**: 1 (50MHz)

### Timing Performance

- **Maximum Frequency**: 50MHz
- **Critical Path**: Audio processing pipeline
- **Setup Slack**: >2ns (typical)

### Power Consumption

- **Static Power**: ~10-20mW
- **Dynamic Power**: ~50-100mW (at 50MHz)
- **Total Power**: ~60-120mW

## Integration with Main Flow

The OpenFPGA implementation integrates seamlessly with the main FPGA flow:

```bash
# From main FPGA directory
cd flow/fpga

# Use OpenFPGA flow
make all TOOL=openfpga

# Use Yosys/NextPNR flow
make all TOOL=yosys_nextpnr
```

## Future Enhancements

1. **Additional FPGA Families**: Support for more FPGA architectures
2. **Advanced Optimization**: Multi-objective optimization for area/timing/power
3. **Automated Testing**: Integration with hardware testing frameworks
4. **Performance Profiling**: Detailed performance analysis tools

## References

- [OpenFPGA Documentation](https://openfpga.readthedocs.io/)
- [VPR Documentation](https://docs.verilogtorouting.org/)
- [MLow Codec Specification](../README.md)
- [FPGA Implementation Guide](../README.md)

## License

This implementation is licensed under Apache-2.0, consistent with the main MLow codec project. 