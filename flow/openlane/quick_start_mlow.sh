#!/bin/bash

#=============================================================================
# MLow Codec OpenLane Quick Start Script
#=============================================================================
# Description: Quick start script for MLow codec developers to begin OpenLane integration
# Author:      Vyges IP Development Team
# Date:        2025-01-27
# License:     Apache-2.0
#=============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MLOW_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Default values
PDK="gf180mcu"
TAG="mlow_$(date +%Y%m%d_%H%M%S)"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Optional Options:
    -p, --pdk PDK             PDK to use (gf180mcu, sky130A) [default: gf180mcu]
    -t, --tag TAG             Run tag [default: timestamp]
    -h, --help                Show this help message

Examples:
    $0 -p gf180mcu
    $0 -p sky130A -t mlow_sky130_v1
    $0 --pdk gf180mcu --tag mlow_test_001

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--pdk)
            PDK="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate PDK
case $PDK in
    gf180mcu|sky130A)
        print_info "Using PDK: $PDK"
        ;;
    *)
        print_error "Unsupported PDK: $PDK"
        print_info "Supported PDKs: gf180mcu, sky130A"
        exit 1
        ;;
esac

# Function to check local prerequisites
check_local_prerequisites() {
    print_header "Checking Local Prerequisites"
    
    # Check if we're in the right directory
    if [[ ! -f "$MLOW_DIR/rtl/mlow_codec.sv" ]]; then
        print_error "MLow RTL files not found. Please run from the correct directory."
        exit 1
    fi
    
    # Check RTL files
    local rtl_files=(
        "mlow_codec.sv"
        "audio_interface.sv"
    )
    
    local missing_files=()
    for file in "${rtl_files[@]}"; do
        if [[ ! -f "$MLOW_DIR/rtl/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        print_success "All RTL files present"
    else
        print_error "Missing RTL files: ${missing_files[*]}"
        exit 1
    fi
    
    # Check OpenLane integration files
    if [[ ! -f "$SCRIPT_DIR/run_openlane_mlow.sh" ]]; then
        print_error "OpenLane integration script not found"
        exit 1
    fi
    
    print_success "Local prerequisites check passed"
}

# Function to run OpenLane flow
run_openlane_flow() {
    print_header "Running OpenLane Flow"
    
    print_info "Design: mlow_codec"
    print_info "PDK: $PDK"
    print_info "Tag: $TAG"
    
    # Run OpenLane flow
    print_info "Starting OpenLane flow (this may take 1-3 hours)..."
    
    if cd "$SCRIPT_DIR" && ./run_openlane_mlow.sh -p "$PDK" -t "$TAG" -v; then
        print_success "OpenLane flow completed successfully"
    else
        print_error "OpenLane flow failed"
        print_info "Check logs for details:"
        print_info "  ls -la designs/mlow_codec/runs/$TAG/logs/"
        exit 1
    fi
}

# Function to show results
show_results() {
    print_header "Results Summary"
    
    local results_dir="$SCRIPT_DIR/designs/mlow_codec/runs/$TAG/results"
    local reports_dir="$SCRIPT_DIR/designs/mlow_codec/runs/$TAG/reports"
    
    if [[ -d "$results_dir" ]]; then
        print_success "Results generated successfully!"
        echo
        print_info "Key files:"
        
        # Check for GDS file
        if [[ -f "$results_dir/final/gds/mlow_codec.gds" ]]; then
            print_success "GDS file: $results_dir/final/gds/mlow_codec.gds"
        fi
        
        # Check for LEF file
        if [[ -f "$results_dir/final/lef/mlow_codec.lef" ]]; then
            print_success "LEF file: $results_dir/final/lef/mlow_codec.lef"
        fi
        
        # Check for netlist
        if [[ -f "$results_dir/final/verilog/gl/mlow_codec.v" ]]; then
            print_success "Netlist: $results_dir/final/verilog/gl/mlow_codec.v"
        fi
        
        echo
        print_info "Reports available in: $reports_dir"
        
        # Show synthesis results
        if [[ -f "$reports_dir/synthesis/1-synthesis.stat.rpt" ]]; then
            echo
            print_info "Synthesis Results:"
            cat "$reports_dir/synthesis/1-synthesis.stat.rpt"
        fi
    else
        print_warning "Results directory not found"
    fi
}

# Function to show next steps
show_next_steps() {
    print_header "Next Steps"
    
    echo
    print_info "Your MLow codec design has been successfully synthesized with $PDK PDK!"
    echo
    print_info "Next steps:"
    echo "  1. Review the results in the generated directories"
    echo "  2. Check performance metrics in the reports"
    echo "  3. Validate timing closure and DRC/LVS results"
    echo "  4. Prepare GDS file for tapeout submission"
    echo
    print_info "To run with the other PDK:"
    echo "  $0 -p sky130A -t mlow_sky130_v1"
    echo
    print_info "For detailed analysis, see the reports directory:"
    echo "  $SCRIPT_DIR/designs/mlow_codec/runs/$TAG/reports/"
}

# Main execution
main() {
    print_header "MLow Codec OpenLane Quick Start"
    echo "This script will take your MLow codec design from RTL to silicon-ready GDS"
    echo
    
    check_local_prerequisites
    run_openlane_flow
    show_results
    show_next_steps
    
    print_header "Quick Start Complete"
    print_success "Your MLow codec design is ready for tapeout!"
}

# Run main function
main "$@" 