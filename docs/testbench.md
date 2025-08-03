# MLow Codec Testbench Documentation

**Version:** 1.0.0  
**Date:** 2025-08-03T03:00:00Z  
**Author:** Vyges Team  
**IP:** vyges/mlow-codec  

## Overview

This document describes the comprehensive testbench infrastructure for the MLow audio codec IP. The testbench supports SystemVerilog, cocotb-based verification, and formal verification methodologies, providing thorough functional verification, performance testing, and quality assurance with enhanced frame buffering and formal verification capabilities.

## Testbench Architecture

### Enhanced Infrastructure

The MLow codec uses a comprehensive, robust testbench infrastructure for easy verification:

#### Key Features
- **Unified Makefile System**: Single command interface for all operations
- **Multi-Simulator Support**: Icarus Verilog and Verilator
- **Simple Commands**: `make run`, `make wave`, `make test`
- **Dependency Management**: Automatic tool verification
- **Clean Output**: Clear success/failure indicators
- **Formal Verification**: Basic assertion-based verification
- **Enhanced Testing**: 12 test categories with frame buffering verification
- **Cocotb Integration**: Python-based verification with comprehensive test scenarios

### Testbench Structure

```
tb/
├── sv_tb/                    # SystemVerilog testbench
│   ├── tb_mlow_codec.sv     # Main SystemVerilog testbench
│   ├── tb_mlow_codec_comprehensive.sv # Enhanced comprehensive testbench
│   ├── tb_mlow_codec_verilator.sv # Verilator-specific testbench
│   └── Makefile             # Enhanced build system
├── cocotb/                   # Cocotb testbench
│   ├── test_mlow_codec.py   # Main cocotb testbench
│   ├── test_example.py      # Example test cases
│   ├── test_config.json     # Test configuration
│   └── Makefile             # Cocotb build system
├── formal/                   # Formal verification
│   ├── verification_checks.sv # Basic assertion-based verification
│   ├── formal_testbench.sv   # Formal verification testbench
│   ├── formal_main.cpp       # Verilator compatibility
│   └── Makefile             # Formal verification build system
└── README.md                # Testbench overview
```

## SystemVerilog Testbench

### Enhanced Features

- **Comprehensive Test Coverage** - All bitrates, bandwidths, and configurations
- **Performance Testing** - Latency and throughput measurement
- **Error Condition Testing** - Invalid inputs and edge cases
- **Audio Pattern Testing** - Various audio signal types
- **Continuous Operation** - Long-running stability tests
- **Coverage Analysis** - Functional and code coverage
- **Enhanced Frame Buffering** - Complete frame collection and bus interface testing
- **16-Sample Frame Testing** - Quick simulation with reduced frame sizes
- **Formal Verification Integration** - Basic assertion-based verification

### Enhanced Test Categories

#### 1. Functional Tests

**Encoding Tests:**
- All bitrate configurations (6-32 kbps)
- All bandwidth modes (NB/WB/SWB)
- Frame size variations (16-960 samples, 16 for quick testing)
- Audio pattern variations

**Decoding Tests:**
- Bitstream decoding verification
- Parameter extraction validation
- Audio reconstruction quality
- Error handling verification

#### 2. Enhanced Frame Buffering Tests

**Frame Collection Verification:**
- Complete frame assembly testing
- Frame boundary detection
- Frame buffer overflow prevention
- Frame data consistency validation

**Full Frame Bus Interface:**
- Frame bus handshake protocol testing
- Parallel frame data access verification
- Frame bus valid/ready signal validation
- Backward compatibility testing

#### 3. Performance Tests

**Latency Measurement:**
- Encoding latency per bitrate
- Decoding latency per bitrate
- End-to-end latency measurement
- Frame processing time analysis
- 16-sample frame processing performance

**Throughput Testing:**
- Maximum sample rate verification
- Continuous frame processing
- Resource utilization monitoring
- Power consumption estimation

#### 4. Audio Pattern Tests

**Signal Types:**
- Sine wave patterns (various frequencies)
- White noise patterns
- Silence/zero patterns
- Impulse response patterns
- Chirp/sweep patterns

**Quality Metrics:**
- Signal-to-noise ratio calculation
- Audio quality assessment
- Bit-exact verification
- POLQA MOS estimation

#### 5. Error Condition Tests

**Invalid Inputs:**
- Invalid bitrate selections
- Invalid bandwidth configurations
- Malformed audio data
- Corrupted packet data

**Edge Cases:**
- Buffer overflow conditions
- Packet loss scenarios
- Backpressure handling
- Mode switching during operation

#### 6. Continuous Operation Tests

**Stability Testing:**
- Extended encoding sessions
- Continuous decoding operation
- Mode switching under load
- Memory leak detection

#### 7. Formal Verification Tests

**Frame Integrity:**
- Frame data consistency checks
- Frame buffer overflow prevention
- Frame completion validation
- Frame data validity verification

**Handshake Protocols:**
- Audio interface handshake validation
- Frame bus handshake verification
- Packet interface handshake testing
- Protocol consistency checks

### Enhanced Test Execution

#### Running Tests (Main Makefile - Recommended)

```bash
# Run all tests
make test

# Run basic simulation
make run

# Generate waveforms
make wave

# Run comprehensive test suite
make test-comprehensive

# Run formal verification
make formal-verify

# Check dependencies
make check-deps

# Clean up
make clean
```

#### Running Tests (Direct Testbench)

```bash
# Navigate to SystemVerilog testbench directory
cd tb/sv_tb

# Run all tests
make test

# Run basic simulation
make run

# Generate waveforms
make wave

# Run comprehensive test suite
make test-comprehensive
```

#### Simulator Support

- **Icarus Verilog** (default) - Open-source simulator
- **Verilator** - Fast open-source simulator

#### Configuration

```bash
# Set simulator
export SIM=verilator

# Run tests
make test

# Show configuration
make config
```

## Cocotb Testbench

### Features

- **Python-based Verification** - Easy test development and maintenance
- **Advanced Test Scenarios** - Complex test sequences with async/await support
- **Quality Metrics** - Automated quality assessment and POLQA MOS estimation
- **Performance Analysis** - Detailed performance profiling and latency measurement
- **Regression Testing** - Automated test execution with XML reporting
- **Multi-Simulator Support** - Icarus Verilog, Verilator, GHDL, ModelSim, Xcelium, VCS
- **Comprehensive Coverage** - Functional and code coverage analysis

### Test Structure

#### Test Classes

**MLowCodecTest Class:**
- Central test management and result tracking
- Audio data generation with multiple patterns
- Quality metric calculation and SNR analysis
- Test result reporting and statistics

**Test Functions:**
- Individual test scenarios with async/await support
- Comprehensive error handling and timeout management
- Detailed logging and waveform generation
- Performance measurement and analysis

#### Test Scenarios

**1. Initialization Tests**
```python
@cocotb.test()
async def test_initialization(dut):
    """Test DUT initialization and reset"""
    # Reset verification
    # Initial state validation
    # Configuration testing
    # Interface signal validation
```

**2. Encoding Functionality Tests**
```python
@cocotb.test()
async def test_encoding_functionality(dut):
    """Test encoding at various bitrates and bandwidths"""
    # Bitrate configuration testing (6-32 kbps)
    # Bandwidth mode testing (NB/WB/SWB)
    # Audio data processing and frame buffering
    # Quality metric validation and POLQA MOS estimation
    # Packet output verification
```

**3. Decoding Functionality Tests**
```python
@cocotb.test()
async def test_decoding_functionality(dut):
    """Test decoding functionality"""
    # Bitstream decoding and parameter extraction
    # Audio reconstruction and synthesis
    # Error detection and handling
    # Quality preservation verification
```

**4. Audio Pattern Tests**
```python
@cocotb.test()
async def test_audio_patterns(dut):
    """Test different audio patterns"""
    # Sine wave testing with various frequencies
    # Noise pattern testing (white, pink, brown)
    # Silence and zero pattern testing
    # Impulse response and chirp testing
    # Quality assessment for each pattern
```

**5. Performance Tests**
```python
@cocotb.test()
async def test_performance_metrics(dut):
    """Test performance metrics and timing"""
    # Latency measurement for encoding/decoding
    # Throughput analysis and real-time capability
    # Resource utilization monitoring
    # Quality vs. performance trade-off analysis
```

**6. Error Condition Tests**
```python
@cocotb.test()
async def test_error_conditions(dut):
    """Test error handling and edge cases"""
    # Invalid input testing and validation
    # Error detection and graceful degradation
    # Recovery mechanisms and state restoration
    # Error reporting and logging
```

**7. End-to-End Tests**
```python
@cocotb.test()
async def test_end_to_end_verification(dut):
    """Test complete encode/decode cycle"""
    # Full pipeline testing from audio input to output
    # Quality preservation through complete cycle
    # Bit-exact verification against reference
    # Performance validation and optimization
```

### Test Execution

#### Running Cocotb Tests

```bash
# Navigate to cocotb testbench directory
cd tb/cocotb

# Run all tests
make test

# Run specific test categories
make test-quick
make test-full
make test-performance
make test-errors
make test-e2e

# Run with coverage
make coverage

# Generate reports
make report
```

#### Simulator Support

- **Icarus Verilog** (default) - Open-source simulator
- **Verilator** - Fast open-source simulator
- **GHDL** - VHDL simulator
- **ModelSim** - Commercial simulator
- **Xcelium** - Commercial simulator
- **VCS** - Commercial simulator

#### Configuration

```bash
# Set simulator
export SIM=verilator

# Run tests
make test

# Check dependencies
make check-deps

# Show configuration
make config
```

#### Test Configuration

The cocotb testbench uses `test_config.json` for configuration:

```json
{
    "test_parameters": {
        "clk_period_ns": 20,
        "sample_rate": 48000,
        "frame_size": 480,
        "max_bitrate": 32000
    },
    "bitrate_configs": {
        "0": {"bitrate": 6000, "quality_target": 60},
        "1": {"bitrate": 8000, "quality_target": 65},
        "2": {"bitrate": 12000, "quality_target": 70},
        "3": {"bitrate": 16000, "quality_target": 75},
        "4": {"bitrate": 20000, "quality_target": 80},
        "5": {"bitrate": 24000, "quality_target": 85},
        "6": {"bitrate": 28000, "quality_target": 90},
        "7": {"bitrate": 32000, "quality_target": 95}
    },
    "bandwidth_configs": {
        "0": {"name": "NarrowBand", "freq_range": "0-4kHz"},
        "1": {"name": "WideBand", "freq_range": "0-8kHz"},
        "2": {"name": "SuperWideBand", "freq_range": "0-16kHz"}
    }
}
```

## Formal Verification

### Basic Assertion-Based Verification

The MLow codec includes a comprehensive formal verification framework using basic assertions compatible with both Icarus Verilog and Verilator:

#### Verification Modules
1. **Verification Checks** (`formal/verification_checks.sv`) - Core assertion logic
2. **Formal Testbench** (`formal/formal_testbench.sv`) - Integration testbench
3. **Formal Main** (`formal/formal_main.cpp`) - Verilator compatibility

#### Verification Categories

##### Frame Integrity Checks (4 checks)
- **Frame Data Consistency** - Verify frame data across outputs
- **Frame Buffer Overflow Prevention** - Prevent buffer overflow conditions
- **Frame Completion Validation** - Ensure proper frame completion
- **Frame Data Validity** - Validate frame data integrity

##### Handshake Protocol Checks (4 checks)
- **Audio Interface Handshake** - Validate audio interface protocols
- **Frame Bus Handshake** - Verify frame bus handshake signals
- **Packet Interface Handshake** - Check packet interface protocols
- **Packet Start/End Consistency** - Validate packet boundary signals

##### Error Handling Checks (3 checks)
- **Error Signal Consistency** - Monitor error condition handling
- **Quality Metric Validity** - Validate quality metric ranges
- **Busy Signal Consistency** - Verify busy signal behavior

##### Flow Control Checks (2 checks)
- **Backpressure Propagation** - Monitor backpressure handling
- **Deadlock Prevention** - Prevent deadlock conditions

#### Coverage Monitoring
- **Frame Transfer Coverage** - Track frame transfer events
- **Audio Backpressure Coverage** - Monitor backpressure scenarios
- **Error Condition Coverage** - Track error occurrences
- **Packet Transfer Coverage** - Monitor packet transfer events

#### Running Formal Verification
```bash
# Run all formal verification checks
make formal-verify

# Run specific verification categories
make formal-frame-integrity
make formal-handshake-protocols

# View verification results
cat logs/formal_verification.log
```

## Enhanced Test Data Generation

### Audio Test Vectors

**Sine Wave Generation:**
```python
def generate_sine_wave(frequency, amplitude, duration, sample_rate):
    """Generate sine wave test vector"""
    samples = int(duration * sample_rate)
    return [amplitude * math.sin(2 * math.pi * frequency * i / sample_rate) 
            for i in range(samples)]
```

**Noise Generation:**
```python
def generate_noise(amplitude, duration, sample_rate):
    """Generate white noise test vector"""
    samples = int(duration * sample_rate)
    return [random.uniform(-amplitude, amplitude) for _ in range(samples)]
```

**Impulse Generation:**
```python
def generate_impulse(position, amplitude, duration, sample_rate):
    """Generate impulse test vector"""
    samples = int(duration * sample_rate)
    impulse_pos = int(position * sample_rate)
    return [amplitude if i == impulse_pos else 0 for i in range(samples)]
```

### Enhanced Frame Test Data

**16-Sample Frame Generation:**
```python
def generate_16_sample_frame(pattern_type, frequency=1000, amplitude=32767):
    """Generate 16-sample test frame for quick simulation"""
    if pattern_type == "sine":
        return [amplitude * math.sin(2 * math.pi * frequency * i / 48000) 
                for i in range(16)]
    elif pattern_type == "ramp":
        return [amplitude * i / 15 for i in range(16)]
    elif pattern_type == "constant":
        return [amplitude] * 16
    else:
        return [0] * 16
```

### Quality Metrics

**Signal-to-Noise Ratio:**
```python
def calculate_snr(original, decoded):
    """Calculate signal-to-noise ratio"""
    signal_power = np.mean(np.array(original) ** 2)
    noise_power = np.mean((np.array(original) - np.array(decoded)) ** 2)
    return 10 * math.log10(signal_power / noise_power) if noise_power > 0 else float('inf')
```

**POLQA MOS Estimation:**
```python
def estimate_polqa_mos(snr_db, bitrate):
    """Estimate POLQA MOS from SNR and bitrate"""
    # Simplified POLQA MOS estimation
    base_mos = 4.5
    snr_factor = min(1.0, snr_db / 30.0)
    bitrate_factor = min(1.0, bitrate / 32000.0)
    return base_mos * snr_factor * bitrate_factor
```

## Enhanced Coverage Analysis

### Functional Coverage

**Bitrate Coverage:**
- Low bitrate (6-8 kbps)
- Medium bitrate (12-20 kbps)
- High bitrate (24-32 kbps)

**Bandwidth Coverage:**
- NarrowBand (8kHz)
- WideBand (16kHz)
- SuperWideBand (32kHz)

**Mode Coverage:**
- Encoding mode
- Decoding mode
- Mode switching

**Frame Coverage:**
- 16-sample frame processing
- Complete frame collection
- Frame boundary conditions
- Frame bus interface usage

### Code Coverage

**Line Coverage:**
- All RTL code paths
- Error handling paths
- Edge case handling
- Frame buffering logic

**Branch Coverage:**
- Conditional statements
- State machine transitions
- Control flow paths
- Frame handshake logic

**Expression Coverage:**
- Complex expressions
- Arithmetic operations
- Logical operations
- Frame data processing

## Enhanced Performance Testing

### Latency Requirements

**Encoding Latency:**
- Target: ≤ 20ms per frame
- Measurement: End-to-end processing time
- Validation: All bitrates and bandwidths
- 16-sample frame processing: ≤ 5ms

**Decoding Latency:**
- Target: ≤ 15ms per frame
- Measurement: Packet to audio output
- Validation: All bitrates and bandwidths
- 16-sample frame processing: ≤ 4ms

### Throughput Requirements

**Sample Rate:**
- Target: 48kHz maximum
- Measurement: Continuous processing
- Validation: Real-time capability

**Bitrate Range:**
- Target: 6-32 kbps
- Measurement: Actual achieved bitrates
- Validation: Quality vs. bitrate trade-off

**Frame Processing:**
- Target: 16-sample frames for quick testing
- Measurement: Frame processing time
- Validation: Real-time capability

### Quality Requirements

**POLQA MOS:**
- Target: 3.9 at 6kbps (2x better than Opus)
- Measurement: Automated quality assessment
- Validation: Reference audio comparison

**SNR Requirements:**
- Target: > 30dB for all bitrates
- Measurement: Signal-to-noise ratio
- Validation: Audio quality metrics

## Enhanced Error Handling

### Error Detection

**Invalid Configuration:**
- Invalid bitrate selection
- Invalid bandwidth selection
- Invalid frame size

**Data Corruption:**
- Corrupted audio input
- Corrupted packet data
- Malformed bitstream

**Resource Exhaustion:**
- Buffer overflow
- Memory exhaustion
- Processing timeout

**Frame Buffer Errors:**
- Frame buffer overflow
- Incomplete frame handling
- Frame data corruption

### Error Recovery

**Graceful Degradation:**
- Fallback to lower bitrate
- Error concealment
- Silent frame insertion

**Recovery Mechanisms:**
- Automatic reset
- State recovery
- Error reporting
- Frame buffer recovery

## Enhanced Test Automation

### Continuous Integration

**Automated Testing:**
- Regression test execution
- Performance regression detection
- Quality metric monitoring
- Formal verification execution

**Test Reporting:**
- XML test results
- Coverage reports
- Performance metrics
- Formal verification reports

**Failure Analysis:**
- Detailed error logs
- Waveform generation
- Debug information
- Frame buffer state analysis

### Test Management

**Test Organization:**
- Test categorization (12 categories)
- Priority assignment
- Execution scheduling
- Formal verification integration

**Result Tracking:**
- Historical performance
- Trend analysis
- Quality metrics
- Frame buffering performance

**Documentation:**
- Test case descriptions
- Expected results
- Known limitations
- Frame buffering test scenarios

## Usage Examples

### Basic Test Execution

```bash
# SystemVerilog tests
cd tb/sv_tb
make test

# Cocotb tests
cd tb/cocotb
make test

# Formal verification
cd formal
make formal-verify
```

### Enhanced Testing

```bash
# Performance testing with coverage
cd tb/sv_tb
make coverage
make analyze-coverage

# Frame buffering verification
make test-comprehensive

# Cocotb comprehensive testing
cd tb/cocotb
make test-full
make coverage

# Formal verification
make formal-verify
make formal-frame-integrity
```

### Custom Test Development

```python
# Add new test case
@cocotb.test()
async def test_custom_scenario(dut):
    """Custom test scenario"""
    # Test implementation
    await test.reset_dut()
    # Custom test logic
    assert result == expected
```

## Troubleshooting

### Common Issues

**Compilation Errors:**
- Check simulator installation
- Verify SystemVerilog syntax
- Check file paths and includes
- Verify formal verification setup
- Check cocotb installation

**Simulation Errors:**
- Verify testbench syntax
- Check signal connections
- Validate test data
- Check frame buffer connections
- Verify cocotb test configuration

**Coverage Issues:**
- Ensure all code paths tested
- Check coverage configuration
- Verify coverage collection
- Include frame buffering coverage

**Formal Verification Issues:**
- Check assertion syntax
- Verify signal connections
- Validate formal testbench setup
- Check simulator compatibility

**Cocotb Issues:**
- Verify Python environment
- Check cocotb installation
- Validate test configuration
- Check simulator compatibility

### Debug Techniques

**Waveform Analysis:**
- Generate VCD files
- Use waveform viewers
- Analyze signal timing
- Examine frame buffer state

**Log Analysis:**
- Enable verbose logging
- Check error messages
- Analyze test results
- Review formal verification logs
- Check cocotb test logs

**Performance Profiling:**
- Measure execution time
- Monitor resource usage
- Identify bottlenecks
- Analyze frame processing performance

## Conclusion

The MLow codec testbench provides comprehensive verification coverage through enhanced testbench methodology. The combination of SystemVerilog testbenches, cocotb-based verification, and formal verification ensures thorough functional verification, performance validation, and quality assurance for the MLow audio codec IP.

The enhanced testbench infrastructure supports multiple simulators, provides detailed coverage analysis, enables automated testing for continuous integration workflows, and includes comprehensive frame buffering verification. This comprehensive testing approach ensures the MLow codec meets all performance, quality, and reliability requirements for real-time communication applications.

### Key Enhancements

- **12 Test Categories** with enhanced frame buffering tests
- **16-Sample Frame Testing** for quick simulation
- **Formal Verification** with basic assertion-based checks
- **Enhanced Frame Buffering** with complete verification
- **Comprehensive Coverage** including frame processing
- **Multi-Simulator Support** with formal verification integration
- **Cocotb Integration** with Python-based verification
- **Advanced Test Scenarios** with async/await support
- **Quality Metrics** with POLQA MOS estimation
- **Performance Analysis** with detailed profiling 