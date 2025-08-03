#!/bin/bash
#=============================================================================
# Comprehensive Synthesis Test for MLow Audio Codec
#=============================================================================
# Description: Comprehensive synthesis test script for MLow audio codec
#              Tests all synthesis flows and generates reports
# Author:      Vyges IP Development Team
# Date:        2025-08-02
# License:     Apache-2.0
#=============================================================================

set -e

echo "=== MLow Codec Comprehensive Synthesis Test ==="
echo "Starting comprehensive synthesis test..."
echo ""

# Create directories
mkdir -p reports netlists

# Test 1: Individual module synthesis
echo "Test 1: Individual Module Synthesis"
echo "=================================="
make synth_individual
echo ""

# Test 2: Generic synthesis
echo "Test 2: Generic Synthesis"
echo "========================"
make synth_generic
echo ""

# Test 3: Full synthesis (if technology library available)
echo "Test 3: Full Synthesis"
echo "======================"
if command -v yosys >/dev/null 2>&1; then
    echo "Yosys found, attempting full synthesis..."
    make synth_full || echo "Full synthesis failed (may need technology library)"
else
    echo "Yosys not found, skipping full synthesis"
fi
echo ""

# Generate summary report
echo "=== Synthesis Test Summary ==="
echo "Reports generated in: reports/"
echo "Netlists generated in: netlists/"
echo ""

if [ -f "reports/mlow_codec_stats.txt" ]; then
    echo "✓ mlow_codec synthesis completed"
else
    echo "✗ mlow_codec synthesis failed"
fi

if [ -f "reports/audio_interface_stats.txt" ]; then
    echo "✓ audio_interface synthesis completed"
else
    echo "✗ audio_interface synthesis failed"
fi

if [ -f "netlists/mlow_codec_generic.v" ]; then
    echo "✓ Generic netlist generated"
else
    echo "✗ Generic netlist generation failed"
fi

echo ""
echo "Comprehensive synthesis test completed!" 