#include "Vtb_mlow_codec_verilator.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vtb_mlow_codec_verilator* top = new Vtb_mlow_codec_verilator;

    // VCD tracing
    VerilatedVcdC* tfp = nullptr;
#ifdef VM_TRACE
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("tb_mlow_codec_verilator.vcd");
#endif

    // Initialize all inputs to 0
    // Note: Verilator generates signal names with underscores
    // We'll use a more generic approach
    
    // Reset sequence
    for (int i = 0; i < 10; ++i) {
        top->eval();
        if (tfp) tfp->dump(i);
    }

    // Run simulation
    for (int i = 0; i < 10000; ++i) {
        top->eval();
        if (tfp) tfp->dump(10 + i);
        if (Verilated::gotFinish()) break;
    }

    if (tfp) {
        tfp->close();
        delete tfp;
    }
    top->final();
    delete top;
    return 0;
} 