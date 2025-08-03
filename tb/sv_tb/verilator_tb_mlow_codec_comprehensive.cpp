//=============================================================================
// Verilator C++ Main Function for MLow Codec Comprehensive Testbench
//=============================================================================
// Description: C++ main function to drive the comprehensive testbench
//
// Author:      Vyges Team
// Date:        2025-08-03T04:45:00Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

#include "Vtb_mlow_codec_comprehensive.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create testbench instance
    Vtb_mlow_codec_comprehensive* tb = new Vtb_mlow_codec_comprehensive;
    
    // Initialize VCD tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    
    // Set VCD filename
    std::string vcd_filename = "tb_mlow_codec_comprehensive.vcd";
    for (int i = 1; i < argc; i++) {
        if (strncmp(argv[i], "+vcd_file=", 10) == 0) {
            vcd_filename = argv[i] + 10;
            break;
        }
    }
    tfp->open(vcd_filename.c_str());
    
    // Run simulation until completion
    int cycle = 0;
    while (!Verilated::gotFinish() && cycle < 50000) {
        tb->eval();
        tfp->dump(cycle);
        cycle++;
    }
    
    // Cleanup
    tfp->close();
    delete tfp;
    delete tb;
    
    std::cout << "Comprehensive testbench simulation completed after " << cycle << " cycles." << std::endl;
    return 0;
} 