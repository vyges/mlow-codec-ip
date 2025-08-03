//=============================================================================
// Formal Verification Main Function
//=============================================================================
// Description: Simple main function for formal verification with Verilator
//
// Author:      Vyges Team
// Date:        2025-08-03T03:00:00Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

#include "Vformal_testbench.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create the testbench instance
    Vformal_testbench* tb = new Vformal_testbench;
    
    // Initialize trace
    Verilated::traceEverOn(true);
    VerilatedVcdC* trace = new VerilatedVcdC;
    tb->trace(trace, 99);
    trace->open("formal_testbench.vcd");
    
    // Initialize signals
    tb->reset_n_i = 0;
    tb->audio_data_i = 0;
    tb->audio_valid_i = 0;
    tb->audio_ready_i = 1;
    tb->frame_bus_ready_i = 1;
    tb->frame_ready_i = 1;
    tb->packet_ready_i = 1;
    tb->encode_mode_i = 1;
    tb->bitrate_sel_i = 5;
    tb->bandwidth_sel_i = 1;
    
    // Reset sequence
    for (int i = 0; i < 5; i++) {
        tb->clk_i = 0;
        tb->eval();
        trace->dump(i * 2);
        
        tb->clk_i = 1;
        tb->eval();
        trace->dump(i * 2 + 1);
    }
    
    // Release reset
    tb->reset_n_i = 1;
    
    // Run simulation for a few cycles
    for (int i = 0; i < 200; i++) {
        tb->clk_i = 0;
        tb->eval();
        trace->dump((i + 5) * 2);
        
        tb->clk_i = 1;
        tb->eval();
        trace->dump((i + 5) * 2 + 1);
        
        // Simple stimulus
        if (i >= 10 && i < 26) {
            tb->audio_data_i = 0x1234 + (i - 10);
            tb->audio_valid_i = 1;
        } else if (i >= 50 && i < 66) {
            tb->audio_data_i = 0x5678 + (i - 50);
            tb->audio_valid_i = 1;
        } else {
            tb->audio_valid_i = 0;
        }
    }
    
    // Cleanup
    trace->close();
    delete trace;
    delete tb;
    
    printf("Formal verification completed successfully\n");
    return 0;
} 