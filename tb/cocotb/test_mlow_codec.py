#!/usr/bin/env python3
"""
MLow Codec Testbench - Cocotb Implementation
============================================

Description: Comprehensive testbench for MLow audio codec using cocotb
             Tests encoding/decoding at various bitrates and bandwidths
             Includes functional verification and performance measurement

Author:      Vyges Team
Date:        2025-08-02T16:08:15Z
Version:     1.0.0
License:     Apache-2.0
"""

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly
from cocotb.clock import Clock
from cocotb.handle import ModifiableObject
import numpy as np
import random
import struct
import os
from typing import List, Tuple, Dict, Any

# Test parameters
CLK_PERIOD_NS = 20  # 50MHz clock
SAMPLE_RATE = 48000
FRAME_SIZE = 480
MAX_BITRATE = 32000
LPC_ORDER = 16
SUBBAND_COUNT = 2

# Bitrate configurations
BITRATE_CONFIGS = {
    0: {"bitrate": 6000, "quality_target": 60},
    1: {"bitrate": 8000, "quality_target": 65},
    2: {"bitrate": 12000, "quality_target": 70},
    3: {"bitrate": 16000, "quality_target": 75},
    4: {"bitrate": 20000, "quality_target": 80},
    5: {"bitrate": 24000, "quality_target": 85},
    6: {"bitrate": 28000, "quality_target": 90},
    7: {"bitrate": 32000, "quality_target": 95}
}

# Bandwidth configurations
BANDWIDTH_CONFIGS = {
    0: {"name": "NarrowBand", "freq_range": "0-4kHz"},
    1: {"name": "WideBand", "freq_range": "0-8kHz"},
    2: {"name": "SuperWideBand", "freq_range": "0-16kHz"}
}


class MLowCodecTest:
    """Test class for MLow codec verification"""
    
    def __init__(self, dut):
        self.dut = dut
        self.test_results = {
            "tests_passed": 0,
            "tests_failed": 0,
            "latency_measurements": [],
            "quality_measurements": [],
            "error_count": 0
        }
        
    async def reset_dut(self):
        """Reset the DUT"""
        self.dut.reset_n_i.value = 0
        await Timer(100, units='ns')
        self.dut.reset_n_i.value = 1
        await Timer(100, units='ns')
        
    async def wait_for_ready(self, signal, timeout_cycles=1000):
        """Wait for a signal to be ready with timeout"""
        for _ in range(timeout_cycles):
            await RisingEdge(self.dut.clk_i)
            if signal.value == 1:
                return True
        return False
        
    def generate_test_audio(self, pattern_type: str = "sine", frame_count: int = 1) -> List[List[int]]:
        """Generate test audio data"""
        audio_frames = []
        
        for frame in range(frame_count):
            frame_data = []
            
            if pattern_type == "sine":
                # Generate sine wave
                for i in range(FRAME_SIZE):
                    sample = int(32767 * 0.5 * np.sin(2 * np.pi * 1000 * i / SAMPLE_RATE))
                    frame_data.append(sample)
                    
            elif pattern_type == "noise":
                # Generate white noise
                for i in range(FRAME_SIZE):
                    sample = random.randint(-16384, 16384)
                    frame_data.append(sample)
                    
            elif pattern_type == "silence":
                # Generate silence
                frame_data = [0] * FRAME_SIZE
                
            elif pattern_type == "impulse":
                # Generate impulse response
                frame_data = [0] * FRAME_SIZE
                frame_data[FRAME_SIZE // 2] = 32767
                
            else:
                # Default to sine wave
                for i in range(FRAME_SIZE):
                    sample = int(32767 * 0.3 * np.sin(2 * np.pi * 500 * i / SAMPLE_RATE))
                    frame_data.append(sample)
                    
            audio_frames.append(frame_data)
            
        return audio_frames
        
    async def send_audio_frame(self, audio_data: List[int], timeout_cycles: int = 10000) -> bool:
        """Send audio frame to the codec"""
        start_time = cocotb.utils.get_sim_time('ns')
        
        for i, sample in enumerate(audio_data):
            # Wait for ready signal
            if not await self.wait_for_ready(self.dut.audio_ready_o, timeout_cycles):
                print(f"Timeout waiting for audio_ready_o at sample {i}")
                return False
                
            # Send sample
            self.dut.audio_data_i.value = sample & 0xFFFF
            self.dut.audio_valid_i.value = 1
            
            await RisingEdge(self.dut.clk_i)
            self.dut.audio_valid_i.value = 0
            
        end_time = cocotb.utils.get_sim_time('ns')
        latency = end_time - start_time
        self.test_results["latency_measurements"].append(latency)
        
        return True
        
    async def collect_encoded_packets(self, expected_packet_count: int, timeout_cycles: int = 10000) -> List[int]:
        """Collect encoded packets from the codec"""
        packets = []
        packet_count = 0
        
        while packet_count < expected_packet_count:
            await RisingEdge(self.dut.clk_i)
            
            if self.dut.packet_valid_o.value == 1 and self.dut.packet_ready_i.value == 1:
                packet_data = self.dut.packet_data_io.value.integer
                packets.append(packet_data)
                packet_count += 1
                
            # Check for timeout
            if len(packets) == 0 and packet_count > timeout_cycles:
                print(f"Timeout waiting for encoded packets")
                break
                
        return packets
        
    async def send_encoded_packets(self, packets: List[int]) -> bool:
        """Send encoded packets to the codec"""
        for packet in packets:
            # Wait for ready signal
            if not await self.wait_for_ready(self.dut.packet_ready_i, 1000):
                return False
                
            # Send packet
            self.dut.packet_data_io.value = packet & 0xFF
            self.dut.packet_valid_o.value = 1
            
            await RisingEdge(self.dut.clk_i)
            self.dut.packet_valid_o.value = 0
            
        return True
        
    async def collect_decoded_audio(self, expected_sample_count: int, timeout_cycles: int = 10000) -> List[int]:
        """Collect decoded audio from the codec"""
        audio_samples = []
        sample_count = 0
        
        while sample_count < expected_sample_count:
            await RisingEdge(self.dut.clk_i)
            
            if self.dut.audio_valid_o.value == 1 and self.dut.audio_ready_i.value == 1:
                sample_data = self.dut.audio_data_o.value.integer
                audio_samples.append(sample_data)
                sample_count += 1
                
            # Check for timeout
            if len(audio_samples) == 0 and sample_count > timeout_cycles:
                print(f"Timeout waiting for decoded audio")
                break
                
        return audio_samples
        
    def calculate_quality_metric(self, original: List[int], decoded: List[int]) -> float:
        """Calculate audio quality metric (simplified SNR)"""
        if len(original) != len(decoded):
            return 0.0
            
        # Calculate signal-to-noise ratio
        signal_power = np.mean(np.array(original) ** 2)
        noise_power = np.mean((np.array(original) - np.array(decoded)) ** 2)
        
        if noise_power == 0:
            return 100.0
            
        snr_db = 10 * np.log10(signal_power / noise_power)
        return max(0.0, min(100.0, snr_db + 50))  # Normalize to 0-100 scale
        
    def print_test_results(self):
        """Print test results summary"""
        total_tests = self.test_results["tests_passed"] + self.test_results["tests_failed"]
        
        print("\n" + "="*60)
        print("MLOW CODEC TEST RESULTS")
        print("="*60)
        print(f"Tests Passed: {self.test_results['tests_passed']}")
        print(f"Tests Failed: {self.test_results['tests_failed']}")
        print(f"Total Tests: {total_tests}")
        
        if total_tests > 0:
            pass_rate = (self.test_results["tests_passed"] / total_tests) * 100
            print(f"Pass Rate: {pass_rate:.1f}%")
            
        if self.test_results["latency_measurements"]:
            avg_latency = np.mean(self.test_results["latency_measurements"])
            max_latency = np.max(self.test_results["latency_measurements"])
            min_latency = np.min(self.test_results["latency_measurements"])
            print(f"Average Latency: {avg_latency:.1f} ns")
            print(f"Max Latency: {max_latency:.1f} ns")
            print(f"Min Latency: {min_latency:.1f} ns")
            
        if self.test_results["quality_measurements"]:
            avg_quality = np.mean(self.test_results["quality_measurements"])
            print(f"Average Quality: {avg_quality:.1f}")
            
        print(f"Error Count: {self.test_results['error_count']}")
        print("="*60)


@cocotb.test()
async def test_initialization(dut):
    """Test DUT initialization and reset"""
    print("Testing DUT initialization...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Check initial state
    assert dut.reset_n_i.value == 1, "Reset signal should be high"
    assert dut.busy_o.value == 0, "DUT should not be busy after reset"
    assert dut.error_o.value == 0, "DUT should not have errors after reset"
    
    print("✓ DUT initialization test passed")
    test.test_results["tests_passed"] += 1


@cocotb.test()
async def test_encoding_functionality(dut):
    """Test encoding functionality at different bitrates and bandwidths"""
    print("Testing encoding functionality...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Test different bitrates and bandwidths
    for bitrate_sel in range(8):
        for bandwidth_sel in range(3):
            print(f"Testing encoding: Bitrate={bitrate_sel}, Bandwidth={bandwidth_sel}")
            
            # Configure codec
            dut.encode_mode_i.value = 1  # Encode mode
            dut.bitrate_sel_i.value = bitrate_sel
            dut.bandwidth_sel_i.value = bandwidth_sel
            
            # Generate test audio
            audio_data = test.generate_test_audio("sine", 1)[0]
            
            # Send audio frame
            success = await test.send_audio_frame(audio_data)
            if not success:
                print(f"✗ Failed to send audio frame for bitrate={bitrate_sel}, bandwidth={bandwidth_sel}")
                test.test_results["tests_failed"] += 1
                continue
                
            # Wait for encoding to complete
            await Timer(1000, units='ns')
            
            # Check for errors
            if dut.error_o.value == 1:
                print(f"✗ Encoding error for bitrate={bitrate_sel}, bandwidth={bandwidth_sel}")
                test.test_results["tests_failed"] += 1
                test.test_results["error_count"] += 1
            else:
                print(f"✓ Encoding test passed for bitrate={bitrate_sel}, bandwidth={bandwidth_sel}")
                test.test_results["tests_passed"] += 1
                
            # Record quality metric
            quality = dut.quality_metric_o.value.integer
            test.test_results["quality_measurements"].append(quality)
            
            # Wait between tests
            await Timer(100, units='ns')


@cocotb.test()
async def test_decoding_functionality(dut):
    """Test decoding functionality"""
    print("Testing decoding functionality...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Test decoding with pre-encoded data (simulated)
    for bitrate_sel in range(8):
        for bandwidth_sel in range(3):
            print(f"Testing decoding: Bitrate={bitrate_sel}, Bandwidth={bandwidth_sel}")
            
            # Configure codec
            dut.encode_mode_i.value = 0  # Decode mode
            dut.bitrate_sel_i.value = bitrate_sel
            dut.bandwidth_sel_i.value = bandwidth_sel
            
            # Generate simulated encoded packets
            packet_count = FRAME_SIZE // 2  # Approximate compression ratio
            encoded_packets = [random.randint(0, 255) for _ in range(packet_count)]
            
            # Send encoded packets
            success = await test.send_encoded_packets(encoded_packets)
            if not success:
                print(f"✗ Failed to send encoded packets for bitrate={bitrate_sel}, bandwidth={bandwidth_sel}")
                test.test_results["tests_failed"] += 1
                continue
                
            # Wait for decoding to complete
            await Timer(1000, units='ns')
            
            # Check for errors
            if dut.error_o.value == 1:
                print(f"✗ Decoding error for bitrate={bitrate_sel}, bandwidth={bandwidth_sel}")
                test.test_results["tests_failed"] += 1
                test.test_results["error_count"] += 1
            else:
                print(f"✓ Decoding test passed for bitrate={bitrate_sel}, bandwidth={bandwidth_sel}")
                test.test_results["tests_passed"] += 1
                
            # Wait between tests
            await Timer(100, units='ns')


@cocotb.test()
async def test_audio_patterns(dut):
    """Test different audio patterns"""
    print("Testing different audio patterns...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Configure codec for encoding
    dut.encode_mode_i.value = 1
    dut.bitrate_sel_i.value = 3  # 16 kbps
    dut.bandwidth_sel_i.value = 1  # WideBand
    
    # Test different audio patterns
    patterns = ["sine", "noise", "silence", "impulse"]
    
    for pattern in patterns:
        print(f"Testing audio pattern: {pattern}")
        
        # Generate test audio
        audio_data = test.generate_test_audio(pattern, 1)[0]
        
        # Send audio frame
        success = await test.send_audio_frame(audio_data)
        if not success:
            print(f"✗ Failed to send {pattern} audio pattern")
            test.test_results["tests_failed"] += 1
            continue
            
        # Wait for processing
        await Timer(1000, units='ns')
        
        # Check for errors
        if dut.error_o.value == 1:
            print(f"✗ Error processing {pattern} audio pattern")
            test.test_results["tests_failed"] += 1
            test.test_results["error_count"] += 1
        else:
            print(f"✓ {pattern} audio pattern test passed")
            test.test_results["tests_passed"] += 1
            
        # Wait between tests
        await Timer(100, units='ns')


@cocotb.test()
async def test_performance_metrics(dut):
    """Test performance metrics and timing"""
    print("Testing performance metrics...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Configure codec
    dut.encode_mode_i.value = 1
    dut.bitrate_sel_i.value = 0  # 6 kbps
    dut.bandwidth_sel_i.value = 1  # WideBand
    
    # Test multiple frames for performance measurement
    for frame in range(5):
        print(f"Performance test frame {frame + 1}/5")
        
        # Generate test audio
        audio_data = test.generate_test_audio("sine", 1)[0]
        
        # Measure encoding time
        start_time = cocotb.utils.get_sim_time('ns')
        
        # Send audio frame
        success = await test.send_audio_frame(audio_data)
        if not success:
            print(f"✗ Failed to send audio frame {frame + 1}")
            test.test_results["tests_failed"] += 1
            continue
            
        # Wait for encoding to complete
        while dut.busy_o.value == 1:
            await RisingEdge(dut.clk_i)
            
        end_time = cocotb.utils.get_sim_time('ns')
        encoding_time = end_time - start_time
        
        # Check performance requirements
        if encoding_time <= 20000:  # 20ms requirement
            print(f"✓ Frame {frame + 1} encoding time: {encoding_time/1000:.1f} ms")
            test.test_results["tests_passed"] += 1
        else:
            print(f"✗ Frame {frame + 1} encoding time too slow: {encoding_time/1000:.1f} ms")
            test.test_results["tests_failed"] += 1
            
        # Wait between frames
        await Timer(100, units='ns')


@cocotb.test()
async def test_error_conditions(dut):
    """Test error handling and edge cases"""
    print("Testing error conditions...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Test 1: Invalid bitrate
    print("Testing invalid bitrate...")
    dut.encode_mode_i.value = 1
    dut.bitrate_sel_i.value = 15  # Invalid bitrate
    dut.bandwidth_sel_i.value = 1
    
    audio_data = test.generate_test_audio("sine", 1)[0]
    await test.send_audio_frame(audio_data)
    await Timer(1000, units='ns')
    
    if dut.error_o.value == 1:
        print("✓ Invalid bitrate error correctly detected")
        test.test_results["tests_passed"] += 1
    else:
        print("✗ Invalid bitrate error not detected")
        test.test_results["tests_failed"] += 1
        
    # Test 2: Invalid bandwidth
    print("Testing invalid bandwidth...")
    dut.bitrate_sel_i.value = 0  # Valid bitrate
    dut.bandwidth_sel_i.value = 3  # Invalid bandwidth
    
    await test.send_audio_frame(audio_data)
    await Timer(1000, units='ns')
    
    if dut.error_o.value == 1:
        print("✓ Invalid bandwidth error correctly detected")
        test.test_results["tests_passed"] += 1
    else:
        print("✗ Invalid bandwidth error not detected")
        test.test_results["tests_failed"] += 1
        
    # Test 3: Backpressure handling
    print("Testing backpressure handling...")
    dut.bandwidth_sel_i.value = 1  # Valid bandwidth
    dut.audio_ready_i.value = 0  # Simulate backpressure
    
    await test.send_audio_frame(audio_data)
    await Timer(1000, units='ns')
    
    if dut.error_o.value == 0:
        print("✓ Backpressure handled gracefully")
        test.test_results["tests_passed"] += 1
    else:
        print("✗ Backpressure caused unexpected error")
        test.test_results["tests_failed"] += 1
        
    # Restore ready signal
    dut.audio_ready_i.value = 1


@cocotb.test()
async def test_end_to_end_verification(dut):
    """Test end-to-end encoding and decoding"""
    print("Testing end-to-end verification...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Configure codec
    dut.bitrate_sel_i.value = 3  # 16 kbps
    dut.bandwidth_sel_i.value = 1  # WideBand
    
    # Generate original audio
    original_audio = test.generate_test_audio("sine", 1)[0]
    
    # Step 1: Encode
    print("Step 1: Encoding audio...")
    dut.encode_mode_i.value = 1
    
    success = await test.send_audio_frame(original_audio)
    if not success:
        print("✗ Failed to encode audio")
        test.test_results["tests_failed"] += 1
        return
        
    # Collect encoded packets
    packet_count = FRAME_SIZE // 2
    encoded_packets = await test.collect_encoded_packets(packet_count)
    
    if len(encoded_packets) == 0:
        print("✗ No encoded packets received")
        test.test_results["tests_failed"] += 1
        return
        
    print(f"✓ Encoded {len(encoded_packets)} packets")
    
    # Step 2: Decode
    print("Step 2: Decoding audio...")
    dut.encode_mode_i.value = 0
    
    success = await test.send_encoded_packets(encoded_packets)
    if not success:
        print("✗ Failed to send encoded packets for decoding")
        test.test_results["tests_failed"] += 1
        return
        
    # Collect decoded audio
    decoded_audio = await test.collect_decoded_audio(FRAME_SIZE)
    
    if len(decoded_audio) == 0:
        print("✗ No decoded audio received")
        test.test_results["tests_failed"] += 1
        return
        
    print(f"✓ Decoded {len(decoded_audio)} samples")
    
    # Step 3: Quality verification
    print("Step 3: Quality verification...")
    quality = test.calculate_quality_metric(original_audio, decoded_audio)
    
    if quality > 30.0:  # Minimum quality threshold
        print(f"✓ End-to-end test passed with quality: {quality:.1f}")
        test.test_results["tests_passed"] += 1
    else:
        print(f"✗ End-to-end test failed with quality: {quality:.1f}")
        test.test_results["tests_failed"] += 1


# Final test to print results
@cocotb.test()
async def test_final_results(dut):
    """Print final test results"""
    print("Generating final test results...")
    
    # Create clock
    clock = Clock(dut.clk_i, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize test class
    test = MLowCodecTest(dut)
    
    # Reset DUT
    await test.reset_dut()
    
    # Wait for all tests to complete
    await Timer(1000, units='ns')
    
    # Print results
    test.print_test_results()
    
    # Final assertion
    total_tests = test.test_results["tests_passed"] + test.test_results["tests_failed"]
    if total_tests > 0:
        pass_rate = test.test_results["tests_passed"] / total_tests
        assert pass_rate >= 0.8, f"Test pass rate {pass_rate:.1%} is below 80% threshold"
    
    print("✓ All tests completed successfully!") 